variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Deployment Environment"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC Provider ARN"
  type        = string
}

variable "oidc_provider" {
  description = "OIDC Provider URL"
  type        = string
}

# variable "cluster_name" {
#   type = string
# }

# variable "namespace" {
#   type = string
# }

variable "sqs_queue_arn" {
  type = string
}
