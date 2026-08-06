# SQS Module

## Overview

Creates the messaging layer used for asynchronous job processing.

## Resources Created

- Primary Queue
- Dead Letter Queue (DLQ)

## Inputs

- project_name
- environment

## Outputs

- queue_name
- queue_arn
- queue_url
- dlq_arn

## Dependencies

None

## Notes

Dead Letter Queue is configured with retry policy.
