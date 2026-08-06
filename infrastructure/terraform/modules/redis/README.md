# Redis Module

## Overview

Deploys Amazon ElastiCache Redis for application caching.

## Resources Created

- Redis Cluster
- Redis Subnet Group

## Inputs

- project_name
- environment
- private_subnets
- security_group

## Outputs

- redis_endpoint
- redis_port

## Dependencies

- VPC Module
- Security Module

## Notes

Single-node Redis cluster for Stage environment.
