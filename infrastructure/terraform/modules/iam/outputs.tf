output "eks_cluster_role_arn" {
  description = "ARN of the EKS Cluster IAM Role"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  description = "ARN of the EKS Node Group IAM Role"
  value       = aws_iam_role.eks_node.arn
}

output "eks_cluster_role_name" {
  description = "Name of the EKS Cluster IAM Role"
  value       = aws_iam_role.eks_cluster.name
}

output "eks_node_role_name" {
  description = "Name of the EKS Node Group IAM Role"
  value       = aws_iam_role.eks_node.name
}

# output "github_actions_role_arn" {
#   description = "ARN of the GitHub Actions IAM Role"
#   value       = aws_iam_role.github_actions.arn
# }

# output "github_actions_role_name" {
#   description = "Name of the GitHub Actions IAM Role"
#   value       = aws_iam_role.github_actions.name
# }


# output "ebs_csi_role_arn" {

#   value = aws_iam_role.ebs_csi.arn
# }
