variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "db_host" {
  description = "RDS endpoint"
  type        = string
}

variable "db_port" {
  description = "RDS port"
  type        = number
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "redis_host" {
  description = "Redis endpoint"
  type        = string
}

variable "redis_port" {
  description = "Redis port"
  type        = number
}

variable "queue_name" {
  description = "SQS Queue Name"
  type        = string
}

variable "queue_url" {
  description = "SQS Queue URL"
  type        = string
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "INFO"
}

variable "worker_poll_interval" {
  description = "Worker polling interval"
  type        = number
  default     = 5
}
