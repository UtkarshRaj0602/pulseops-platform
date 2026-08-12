# Deployment Runbook

## Infrastructure

```bash
cd infrastructure/terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file=environments/stage/terraform.tfvars
terraform apply -var-file=environments/stage/terraform.tfvars
```

## Application

Preferred deployment path: GitHub Actions.

The workflow builds/pushes images, configures EKS, applies manifests, runs the migration Job, updates deployments to the Git SHA and verifies rollout.

## Verification

```bash
kubectl get nodes
kubectl get pods -n pulseops
kubectl get svc -n pulseops
kubectl get ingress -n pulseops
kubectl get hpa -n pulseops
kubectl get job -n pulseops
```

## API

```bash
kubectl exec -n pulseops deploy/backend --   python -c "import urllib.request; print(urllib.request.urlopen('http://localhost:8000/jobs').read().decode())"
```

Submit a UI job and verify `202`, then `COMPLETED`.
