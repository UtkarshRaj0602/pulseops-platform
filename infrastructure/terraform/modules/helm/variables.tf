variable "cluster_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "alb_controller_role_arn" {
  type = string
}

variable "ebs_csi_role_arn" {
  type = string
}

variable "external_secrets_role_arn" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}
