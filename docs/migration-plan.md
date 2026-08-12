# Stage to Production Migration Plan

1. Inventory workloads, dependencies, state, secrets, networking and IAM.
2. Create production-specific Terraform variables and secrets.
3. Harden production: HTTPS, backups, Multi-AZ, Redis HA, NAT redundancy, workload IAM and monitoring.
4. Validate infrastructure, application, migration, SQS, Redis and rollback behavior.
5. Apply the reviewed production plan.
6. Deploy the tested immutable image.
7. Run migration.
8. Validate ALB and submit an end-to-end job.
9. Open production traffic.

Prefer incremental promotion over a single large cutover.
