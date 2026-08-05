variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "node_type" {
  type    = string
  default = "cache.t4g.micro"
}

variable "engine_version" {
  type    = string
  default = "7.1"
}

variable "private_subnets" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}
