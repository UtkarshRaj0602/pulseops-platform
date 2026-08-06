# RDS Module

## Overview

Deploys an Amazon RDS PostgreSQL instance for the PulseOps backend.

## Resources Created

- PostgreSQL Database
- Database Instance

## Inputs

- project_name
- environment
- database subnet group
- security group
- database credentials

## Outputs

- db_endpoint
- db_address
- db_port
- db_name

## Dependencies

- VPC Module
- Security Module
- Secrets Module

## Notes

Configured for Stage environment with encryption enabled.
