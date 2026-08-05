variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "pulseops"
}
