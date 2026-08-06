# ECR Module

## Overview

Creates Amazon Elastic Container Registry (ECR) repositories used for application images.

## Resources Created

- Frontend Repository
- Backend Repository
- Worker Repository
- Lifecycle Policies

## Inputs

- project_name
- environment

## Outputs

- repository_names
- repository_urls

## Dependencies

None

## Notes

Image scanning and immutable tags are enabled.
