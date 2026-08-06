# VPC Module

## Overview

This module provisions the networking layer for the PulseOps Platform. It creates a highly available VPC with public and private subnets across multiple Availability Zones using the official AWS VPC Terraform module.

## Resources Created

- VPC
- Public Subnets
- Private Subnets
- Internet Gateway
- NAT Gateway
- Route Tables
- Route Table Associations

## Inputs

- project_name
- environment
- vpc_cidr
- availability_zones
- public_subnets
- private_subnets

## Outputs

- vpc_id
- public_subnets
- private_subnets
- database_subnet_group_name

## Dependencies

None

## Notes

Uses the official terraform-aws-modules/vpc/aws community module.
