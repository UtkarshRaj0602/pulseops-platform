# GitHub Actions Workflow

The Stage workflow builds the frontend, backend and worker images, pushes them to ECR, configures EKS access, applies Kubernetes resources, runs the database migration Job, updates deployments to the Git commit SHA and validates rollout.

## Kubernetes deployment sequence

```text
Git push
 -> Build images
 -> Push to ECR
 -> Configure EKS
 -> Ensure pulseops namespace
 -> Apply Kubernetes manifests
 -> Run Alembic migration Job
 -> Set frontend/backend/worker images to GITHUB_SHA
 -> Wait for rollout
 -> Validate
```

The migration step applies:

```bash
kubectl apply -f infrastructure/kubernetes/jobs/db-migration.yaml
kubectl wait --for=condition=complete job/pulseops-db-migration -n pulseops --timeout=180s
kubectl logs job/pulseops-db-migration -n pulseops
```

Application deployments use immutable commit-SHA image tags rather than relying on `latest`.

Example:

```bash
kubectl set image deployment/backend   backend=<ECR_BACKEND>:${GITHUB_SHA}   --namespace=pulseops
```
