# Kubernetes

Application namespace:

```text
pulseops
```

## Workloads

- frontend — React/Nginx
- backend — FastAPI
- worker — SQS consumer
- pulseops-db-migration — Alembic Job

## Services

Frontend and backend use internal ClusterIP services. The backend exposes port 80 to target port 8000.

## Ingress

The AWS Load Balancer Controller reconciles the Kubernetes Ingress into an AWS Application Load Balancer.

## Configuration

ConfigMaps contain non-secret configuration. External Secrets supplies sensitive values from AWS Secrets Manager.

## Verification

```bash
kubectl get nodes
kubectl get pods -n pulseops
kubectl get svc -n pulseops
kubectl get ingress -n pulseops
kubectl get job -n pulseops
kubectl get hpa -n pulseops
```
