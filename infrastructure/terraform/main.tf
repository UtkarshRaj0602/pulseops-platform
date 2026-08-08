module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

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

  cluster_version = var.cluster_version

  vpc_id = module.vpc.vpc_id

  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets

  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn

  node_security_group_id = module.security.eks_node_security_group_id

  desired_size        = var.desired_size
  min_size            = var.min_size
  max_size            = var.max_size
  node_instance_types = var.node_instance_types
}

module "irsa" {

  source = "./modules/irsa"

  project_name = var.project_name
  environment  = var.environment

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider     = module.eks.oidc_provider

}

module "namespace" {

  source = "./modules/namespace"

  namespace = var.namespace

  project_name = var.project_name

  environment = var.environment

}

# module "helm" {

#   source = "./modules/helm"

#   project_name = var.project_name
#   environment  = var.environment

#   cluster_name = module.eks.cluster_name

#   region = var.aws_region
#   vpc_id = module.vpc.vpc_id

#   alb_controller_role_arn   = module.irsa.alb_controller_role_arn
#   ebs_csi_role_arn          = module.irsa.ebs_csi_role_arn
#   external_secrets_role_arn = module.irsa.external_secrets_role_arn

#   depends_on = [
#     module.eks,
#     module.irsa
#   ]
# }

# module "k8s_secrets" {

#   source = "./modules/k8s-secrets"

#   namespace = module.namespace.namespace

#   aws_region = var.aws_region

#   database_secret_name = module.secrets.database_secret_name

#   database_secret_arn = module.secrets.database_secret_arn

#   depends_on = [
#     module.helm,
#     module.irsa
#   ]

# }

# module "configmap" {

#   source = "./modules/configmap"

#   namespace  = var.namespace
#   environment = var.environment

#   aws_region = var.aws_region

#   db_host = module.rds.db_endpoint
#   db_port = var.db_port
#   db_name = var.db_name

#   redis_host = module.redis.redis_endpoint
#   redis_port = var.redis_port

#   queue_name = module.sqs.queue_name

#   log_level = var.log_level

#   worker_poll_interval = var.worker_poll_interval

#   depends_on = [
#     module.namespace,
#     module.rds,
#     module.redis,
#     module.sqs
#   ]
# }

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}
