# Terraform Infrastructure

Terraform provisions the AWS infrastructure and Kubernetes-facing integrations.

## Modules

- `vpc` — networking and subnet topology
- `security` — security groups/network controls
- `iam` — AWS roles and policies
- `eks` — EKS cluster, nodes and add-ons
- `ecr` — container registries
- `sqs` — asynchronous job queue
- `rds` — PostgreSQL
- `redis` — ElastiCache Redis
- `secrets-manager` — secret storage
- `irsa` — Kubernetes/IAM integration
- `external-secrets` — AWS Secrets Manager to Kubernetes integration
- `configmap` — application configuration
- `helm` — Helm-managed dependencies
- `route53` — DNS integration

## Commands

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file=environments/stage/terraform.tfvars
terraform apply -var-file=environments/stage/terraform.tfvars
```

Environment-specific values remain outside reusable modules.
