# IRSA Module

## Overview

Creates IAM Roles for Kubernetes Service Accounts (IRSA).

## Resources Created

- AWS Load Balancer Controller Role
- EBS CSI Driver Role
- External Secrets Role

## Inputs

- OIDC Provider
- Project Name
- Environment

## Outputs

- alb_controller_role_arn
- ebs_csi_role_arn
- external_secrets_role_arn

## Dependencies

- EKS Module

## Notes

Uses IAM Roles for Service Accounts (IRSA) to eliminate static AWS credentials inside Kubernetes.
