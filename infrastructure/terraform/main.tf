module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "security" {

  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.vpc.vpc_id

}

module "ecr" {

  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment

}

module "sqs" {

  source = "./modules/sqs"

  project_name = var.project_name
  environment  = var.environment

}

module "secrets" {

  source = "./modules/secrets"

  project_name = var.project_name

  environment = var.environment

}

module "rds" {

  source = "./modules/rds"

  project_name = var.project_name

  environment = var.environment

  db_subnet_group_name = module.vpc.database_subnet_group_name

  security_group_id = module.security.rds_security_group_id

  db_username = module.secrets.database_username

  db_password = module.secrets.database_password

}

module "redis" {

  source = "./modules/redis"

  project_name = var.project_name
  environment  = var.environment

  private_subnets = module.vpc.private_subnets

  security_group_id = module.security.redis_security_group_id

}

module "eks" {

  source = "./modules/eks"

  project_name = var.project_name
  environment  = var.environment

  cluster_version = "1.33"

  vpc_id = module.vpc.vpc_id

  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets

  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn

  node_security_group_id = module.security.eks_node_security_group_id

}

module "irsa" {

  source = "./modules/irsa"

  project_name = var.project_name
  environment  = var.environment

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider     = module.eks.oidc_provider

}

module "helm" {

  source = "./modules/helm"

  project_name = var.project_name
  environment  = var.environment

  cluster_name = module.eks.cluster_name

  region = var.aws_region
  vpc_id = module.vpc.vpc_id

  alb_controller_role_arn   = module.irsa.alb_controller_role_arn
  ebs_csi_role_arn          = module.irsa.ebs_csi_role_arn
  external_secrets_role_arn = module.irsa.external_secrets_role_arn

  depends_on = [
    module.eks,
    module.irsa
  ]
}
