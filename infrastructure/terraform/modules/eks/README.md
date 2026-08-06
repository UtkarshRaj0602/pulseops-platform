# EKS Module

## Overview

Creates the Amazon EKS cluster and managed node groups.

## Resources Created

- Amazon EKS Cluster
- Managed Node Group
- OIDC Provider
- Core Add-ons (CoreDNS, kube-proxy, VPC CNI, EBS CSI)

## Inputs

- VPC
- Private Subnets
- IAM Roles
- Security Groups

## Outputs

- cluster_name
- cluster_endpoint
- cluster_version
- oidc_provider
- oidc_provider_arn

## Dependencies

- VPC Module
- IAM Module
- Security Module

## Notes

Uses the official terraform-aws-modules/eks/aws module.
