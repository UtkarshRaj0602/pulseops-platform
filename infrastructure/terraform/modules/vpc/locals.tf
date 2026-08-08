locals {

  name = "${var.project_name}-${var.environment}"

  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

}
