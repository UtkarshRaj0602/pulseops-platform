# Helm Module

## Overview

Deploys Kubernetes platform components using the Terraform Helm Provider.

## Helm Charts Installed

- AWS Load Balancer Controller
- Metrics Server
- External Secrets
- kube-prometheus-stack

## Inputs

- cluster_name
- region
- vpc_id
- IRSA Role ARNs

## Outputs

- Helm Release Names
- Helm Release Namespaces

## Dependencies

- EKS Module
- IRSA Module

## Notes

Platform components are installed after the EKS cluster becomes available.
