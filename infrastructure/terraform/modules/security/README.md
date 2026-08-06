# Security Module

## Overview

Creates all Security Groups required by the PulseOps Platform.

## Resources Created

- ALB Security Group
- EKS Cluster Security Group
- EKS Node Security Group
- RDS Security Group
- Redis Security Group

## Inputs

- project_name
- environment
- vpc_id

## Outputs

- alb_security_group_id
- eks_security_group_id
- eks_node_security_group_id
- rds_security_group_id
- redis_security_group_id

## Dependencies

- VPC Module

## Notes

All resources follow the principle of least privilege.
