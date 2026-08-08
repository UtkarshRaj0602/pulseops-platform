###########################################################
# General
###########################################################

output "project_name" {
  description = "Project Name"
  value       = var.project_name
}

output "environment" {
  description = "Deployment Environment"
  value       = var.environment
}

output "aws_region" {
  description = "AWS Region"
  value       = var.aws_region
}

###########################################################
# VPC
###########################################################

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public Subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private Subnet IDs"
  value       = module.vpc.private_subnets
}

output "database_subnets" {
  description = "Database Subnet IDs"
  value       = module.vpc.database_subnets
}

###########################################################
# EKS
###########################################################

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "EKS Kubernetes Version"
  value       = module.eks.cluster_version
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN"
  value       = module.eks.oidc_provider_arn
}

###########################################################
# RDS
###########################################################

output "db_endpoint" {
  description = "RDS Endpoint"
  value       = module.rds.db_endpoint
}

output "db_port" {
  description = "RDS Port"
  value       = module.rds.db_port
}

output "db_name" {
  description = "Database Name"
  value       = module.rds.db_name
}

###########################################################
# Redis
###########################################################

output "redis_endpoint" {
  description = "Redis Endpoint"
  value       = module.redis.redis_endpoint
}

output "redis_port" {
  description = "Redis Port"
  value       = module.redis.redis_port
}

###########################################################
# SQS
###########################################################

output "sqs_queue_name" {
  description = "SQS Queue Name"
  value       = module.sqs.queue_name
}

output "sqs_queue_url" {
  description = "SQS Queue URL"
  value       = module.sqs.queue_url
}

output "sqs_queue_arn" {
  description = "SQS Queue ARN"
  value       = module.sqs.queue_arn
}

###########################################################
# ECR
###########################################################

output "backend_repository_url" {
  description = "Backend ECR Repository URL"
  value       = module.ecr.backend_repository_url
}

output "frontend_repository_url" {
  description = "Frontend ECR Repository URL"
  value       = module.ecr.frontend_repository_url
}

output "worker_repository_url" {
  description = "Worker ECR Repository URL"
  value       = module.ecr.worker_repository_url
}

###########################################################
# Secrets Manager
###########################################################

output "database_secret_name" {
  description = "Database Secret Name"
  value       = module.secrets.database_secret_name
}

output "database_secret_arn" {
  description = "Database Secret ARN"
  value       = module.secrets.database_secret_arn
}
