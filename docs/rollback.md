# Rollback

## Application

The deployment uses Git commit SHA image tags.

```bash
kubectl rollout history deployment/backend -n pulseops
kubectl rollout history deployment/frontend -n pulseops
kubectl rollout history deployment/worker -n pulseops
```

Rollback a deployment:

```bash
kubectl rollout undo deployment/backend -n pulseops
```

Repeat for frontend/worker as required.

## Database

Alembic downgrades must be deliberate and tested against the previous application version.

## Terraform

Terraform has no generic undo command. Correct the desired configuration, review the plan and apply the corrective state. Avoid routine `-target`.
