# Architecture

## Request flow

```text
User
  |
  v
Application Load Balancer
  |
  v
React + Nginx
  |
  | POST /jobs
  v
FastAPI Backend
  |              |
  |              +--> Amazon SQS --> Kubernetes Worker
  |                                      |       |
  v                                      v       v
RDS PostgreSQL                         RDS     Redis
```

## Lifecycle

```text
QUEUED -> PROCESSING -> COMPLETED
                                           -> FAILED
```

The backend persists the job and publishes SQS work before returning HTTP 202. The worker processes independently, updates PostgreSQL and caches the result in Redis.

## Component roles

- EKS: application runtime.
- ALB: external entry point.
- Nginx: frontend server and API reverse proxy.
- FastAPI: application API.
- SQS: asynchronous decoupling and buffering.
- Worker: background processing.
- RDS PostgreSQL: durable source of truth.
- ElastiCache Redis: cache.
- ECR: image registry.
- Secrets Manager + External Secrets: secret management.
- IAM: AWS authorization.
- Terraform: infrastructure as code.
