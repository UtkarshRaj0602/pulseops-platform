# Incident Runbook

## API unavailable

```bash
kubectl get pods -n pulseops
kubectl get svc -n pulseops
kubectl get ingress -n pulseops
kubectl logs -n pulseops deploy/backend --tail=100
```

## Worker not processing

```bash
kubectl get pods -n pulseops
kubectl logs -n pulseops deploy/worker --tail=100
kubectl get configmap worker-config -n pulseops -o yaml
```

Verify SQS permissions and queue configuration.

## ImagePullBackOff

```bash
kubectl describe pod <pod> -n pulseops
```

Check image name/tag, ECR account/region and pull permissions. Prefer commit SHA tags.

## Migration failure

```bash
kubectl describe job pulseops-db-migration -n pulseops
kubectl logs job/pulseops-db-migration -n pulseops
```

Check image, database endpoint, credentials, network access and Alembic revision chain.

## Redis

```bash
kubectl exec -n pulseops deploy/worker --   python -c "import os,redis; r=redis.Redis(host=os.environ['REDIS_HOST'],port=int(os.environ.get('REDIS_PORT',6379)),socket_connect_timeout=5); print(r.ping())"
```

## General rule

Capture logs/events first, diagnose second, change third.
