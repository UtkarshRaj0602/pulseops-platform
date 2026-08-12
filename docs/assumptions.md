# Assumptions, Trade-offs and Known Limitations

## Assumptions

- Stage is the demonstrated environment.
- PostgreSQL is the durable source of truth.
- Redis is a cache.
- SQS provides asynchronous decoupling.
- EKS runs the application.
- Terraform owns infrastructure configuration.

## Production hardening to review

- Enable HTTPS/TLS on the ALB.
- Review RDS backups, retention and Multi-AZ.
- Review Redis high availability.
- Review NAT redundancy.
- Scope workload IAM permissions.
- Complete monitoring and alerting.
- Populate and review production Terraform variables.
- Verify Route53/DNS configuration.
- Maintain automated smoke tests.
