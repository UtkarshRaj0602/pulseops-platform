#!/usr/bin/env python3
"""PulseOps end-to-end smoke test for the Stage environment."""

import argparse, json, os, shutil, subprocess, sys, time, urllib.error, urllib.request

try:
    import boto3
except ImportError:
    boto3 = None


def http(base, method, path, payload=None, timeout=15):
    data = json.dumps(payload).encode() if payload is not None else None
    headers = {
        "Accept": "application/json, text/plain, */*",
        "User-Agent": "pulseops-smoke-test/1.0",
    }
    if data:
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(
        base.rstrip("/") + path, data=data, headers=headers, method=method
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            raw = r.read().decode("utf-8", "replace")
            try:
                body = json.loads(raw)
            except Exception:
                body = raw
            return r.status, body
    except urllib.error.HTTPError as e:
        raw = e.read().decode("utf-8", "replace")
        try:
            body = json.loads(raw)
        except Exception:
            body = raw
        return e.code, body


def cmd(*args):
    try:
        p = subprocess.run(
            args, text=True, capture_output=True, timeout=30, check=False
        )
        return p.returncode == 0, (p.stdout or p.stderr).strip()
    except Exception as e:
        return False, str(e)


def check(results, name, ok, detail=""):
    results.append(ok)
    print(f"[{'PASS' if ok else 'FAIL'}] {name}")
    if detail:
        print(f"       {detail}")


def k8s_checks(ns, results):
    if not shutil.which("kubectl"):
        check(results, "kubectl available", False, "kubectl not found")
        return
    check(results, "kubectl available", True)
    ok, out = cmd("kubectl", "get", "namespace", ns)
    check(results, "Kubernetes namespace exists", ok, out)
    for dep in ("backend", "frontend", "worker"):
        ok, out = cmd(
            "kubectl",
            "get",
            "deployment",
            dep,
            "-n",
            ns,
            "-o",
            "jsonpath={.status.readyReplicas}/{.status.replicas}",
        )
        ready = out.split("/") if "/" in out else []
        good = (
            ok
            and len(ready) == 2
            and ready[0] == ready[1]
            and ready[0] not in ("", "0")
        )
        check(results, f"Deployment {dep} ready", good, out)
    for svc in ("backend", "frontend"):
        ok, out = cmd("kubectl", "get", "service", svc, "-n", ns)
        check(results, f"Service {svc} exists", ok, out)
    ok, out = cmd("kubectl", "get", "ingress", "pulseops-ingress", "-n", ns)
    check(results, "PulseOps ingress exists", ok, out)
    ok, out = cmd(
        "kubectl",
        "get",
        "job",
        "pulseops-db-migration",
        "-n",
        ns,
        "-o",
        "jsonpath={.status.succeeded}",
    )
    check(results, "Database migration completed", ok and out == "1", out)


def aws_checks(args, results):
    if boto3 is None:
        check(results, "boto3 available", False, "pip install boto3")
        return
    session = boto3.Session(region_name=args.region)
    try:
        c = session.client("eks").describe_cluster(name=args.cluster)["cluster"]
        check(
            results,
            "EKS cluster ACTIVE",
            c.get("status") == "ACTIVE",
            f"{c.get('name')} / {c.get('status')} / v{c.get('version')}",
        )
    except Exception as e:
        check(results, "EKS cluster ACTIVE", False, str(e))
    try:
        sqs = session.client("sqs")
        q = sqs.get_queue_url(QueueName=args.queue)["QueueUrl"]
        a = sqs.get_queue_attributes(
            QueueUrl=q,
            AttributeNames=[
                "ApproximateNumberOfMessages",
                "ApproximateNumberOfMessagesNotVisible",
            ],
        )["Attributes"]
        check(
            results,
            "SQS queue exists",
            True,
            f"visible={a.get('ApproximateNumberOfMessages')}, in_flight={a.get('ApproximateNumberOfMessagesNotVisible')}",
        )
    except Exception as e:
        check(results, "SQS queue exists", False, str(e))
    try:
        r = session.client("ecr").describe_repositories(
            repositoryNames=[args.ecr_repo]
        )["repositories"][0]
        check(
            results, "Backend ECR repository exists", True, r.get("repositoryUri", "")
        )
    except Exception as e:
        check(results, "Backend ECR repository exists", False, str(e))
    try:
        d = session.client("rds").describe_db_instances(DBInstanceIdentifier=args.rds)[
            "DBInstances"
        ][0]
        check(
            results,
            "RDS PostgreSQL available",
            d.get("DBInstanceStatus") == "available",
            f"{d.get('DBInstanceIdentifier')} / {d.get('DBInstanceStatus')}",
        )
    except Exception as e:
        check(results, "RDS PostgreSQL available", False, str(e))
    try:
        g = session.client("elasticache").describe_replication_groups(
            ReplicationGroupId=args.redis
        )["ReplicationGroups"][0]
        check(
            results,
            "ElastiCache Redis available",
            g.get("Status") == "available",
            f"{g.get('ReplicationGroupId')} / {g.get('Status')}",
        )
    except Exception as e:
        check(results, "ElastiCache Redis available", False, str(e))
    try:
        s = session.client("secretsmanager").describe_secret(SecretId=args.secret)
        check(results, "Database secret exists", True, s.get("Name", ""))
    except Exception as e:
        check(results, "Database secret exists", False, str(e))


def main():
    p = argparse.ArgumentParser(description="PulseOps Stage smoke test")
    p.add_argument("--base-url", default=os.getenv("PULSEOPS_BASE_URL"), required=False)
    p.add_argument("--text", default="pulseops smoke test")
    p.add_argument("--poll-timeout", type=int, default=60)
    p.add_argument("--poll-interval", type=float, default=2)
    p.add_argument("--namespace", default="pulseops")
    p.add_argument("--region", default=os.getenv("AWS_REGION", "ap-south-1"))
    p.add_argument("--cluster", default="pulseops-stage")
    p.add_argument("--queue", default="pulseops-stage-jobs")
    p.add_argument("--ecr-repo", default="pulseops-stage-backend")
    p.add_argument("--rds", default="pulseops-stage-postgres")
    p.add_argument("--redis", default="pulseops-stage-redis")
    p.add_argument("--secret", default="pulseops-stage-database")
    p.add_argument("--k8s-checks", action="store_true")
    p.add_argument("--aws-checks", action="store_true")
    args = p.parse_args()
    if not args.base_url:
        p.error("--base-url is required or set PULSEOPS_BASE_URL")
    results = []
    print("=" * 70)
    print("PulseOps Smoke Test")
    print("=" * 70)
    print(f"Base URL: {args.base_url}\n")

    print("--- APPLICATION ---")
    status, body = http(args.base_url, "GET", "/")
    check(
        results,
        "Frontend reachable through ALB",
        status == 200 and isinstance(body, str) and "<html" in body.lower(),
        f"HTTP {status}",
    )
    status, body = http(args.base_url, "GET", "/jobs")
    check(
        results,
        "GET /jobs works",
        status == 200 and isinstance(body, list),
        f"HTTP {status}; jobs={len(body) if isinstance(body,list) else 'N/A'}",
    )
    status, body = http(args.base_url, "POST", "/jobs", {"text": args.text})
    job_id = body.get("job_id") if isinstance(body, dict) else None
    check(
        results,
        "POST /jobs returns 202",
        status == 202 and bool(job_id),
        f"HTTP {status}; job_id={job_id}",
    )

    completed = None
    if job_id:
        deadline = time.time() + args.poll_timeout
        while time.time() < deadline:
            s, b = http(args.base_url, "GET", f"/jobs/{job_id}")
            if s == 200 and isinstance(b, dict):
                completed = b
                if b.get("status") in ("COMPLETED", "FAILED"):
                    break
            s, jobs = http(args.base_url, "GET", "/jobs")
            if s == 200 and isinstance(jobs, list):
                for j in jobs:
                    if str(j.get("id")) == str(job_id):
                        completed = j
                        if j.get("status") in ("COMPLETED", "FAILED"):
                            break
            if completed and completed.get("status") in ("COMPLETED", "FAILED"):
                break
            time.sleep(args.poll_interval)
        ok = (
            isinstance(completed, dict)
            and completed.get("status") == "COMPLETED"
            and completed.get("result") == args.text.upper()
        )
        check(
            results,
            "Async worker completed job",
            ok,
            f"status={completed.get('status') if completed else None}; result={completed.get('result') if completed else None}",
        )
        s, jobs = http(args.base_url, "GET", "/jobs")
        visible = isinstance(jobs, list) and any(
            str(j.get("id")) == str(job_id) and j.get("result") == args.text.upper()
            for j in jobs
        )
        check(
            results,
            "Completed result visible in GET /jobs",
            s == 200 and visible,
            f"HTTP {s}",
        )

    if args.k8s_checks:
        print("\n--- KUBERNETES ---")
        k8s_checks(args.namespace, results)
    if args.aws_checks:
        print("\n--- AWS ---")
        aws_checks(args, results)

    passed = sum(results)
    failed = len(results) - passed
    print("\n" + "=" * 70)
    print(f"RESULT: {passed} passed / {failed} failed")
    print("=" * 70)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
