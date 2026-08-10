variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "node_security_group_id" {
  type = string
}

variable "node_instance_types" {
  type = list(string)
}

variable "desired_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

# variable "ebs_csi_role_arn" {
#   description = "IAM role ARN used by the AWS EBS CSI driver through EKS Pod Identity"
#   type        = string
# }

variable "github_actions_role_arn" {
  description = "ARN of the externally managed GitHub Actions IAM role"
  type        = string
}

variable "cluster_name" {
  type = string
}
