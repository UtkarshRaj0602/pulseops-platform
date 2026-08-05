locals {

  name_prefix = "${var.project_name}-${var.environment}"

  repositories = [
    "frontend",
    "backend",
    "worker"
  ]

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

}
