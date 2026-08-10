output "role_arn" {
  description = "Cluster Autoscaler IAM role ARN"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "role_name" {
  description = "Cluster Autoscaler IAM role name"
  value       = aws_iam_role.cluster_autoscaler.name
}

output "service_account_name" {
  description = "Cluster Autoscaler service account"
  value       = var.service_account_name
}
