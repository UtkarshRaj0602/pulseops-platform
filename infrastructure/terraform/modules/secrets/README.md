# Secrets Module

## Overview

Creates AWS Secrets Manager secrets used by the platform.

## Resources Created

- Database Credentials Secret
- Random Password

## Inputs

- project_name
- environment
- db_username

## Outputs

- database_secret_arn
- database_secret_name
- database_username

## Dependencies

None

## Notes

Passwords are generated automatically using the Random provider.
