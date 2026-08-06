variable "namespace" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "secret_store_name" {
  type    = string
  default = "aws-secretsmanager"
}

variable "database_secret_name" {
  type = string
}

variable "database_secret_arn" {
  type = string
}
