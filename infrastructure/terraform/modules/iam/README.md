# IAM Module

## Overview

Creates IAM roles and policies required by AWS infrastructure components.

## Resources Created

- EKS Cluster IAM Role
- EKS Node IAM Role
- Managed Policy Attachments

## Inputs

- project_name
- environment

## Outputs

- eks_cluster_role_arn
- eks_node_role_arn

## Dependencies

None

## Notes

Uses AWS managed policies wherever possible.
