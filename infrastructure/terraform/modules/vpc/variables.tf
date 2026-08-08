variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "Primary VPC CIDR"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks, one per availability zone"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private application subnet CIDR blocks, one per availability zone"
  type        = list(string)
}

variable "database_subnets" {
  description = "Private database subnet CIDR blocks, one per availability zone"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Create NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Using a single NAT Gateway to reduce cost"
  type        = bool
  default     = true
}
