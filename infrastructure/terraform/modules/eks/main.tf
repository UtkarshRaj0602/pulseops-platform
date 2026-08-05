module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id = var.vpc_id

  subnet_ids = var.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  ####################################################
  # IAM
  ####################################################

  create_iam_role = false

  iam_role_arn = var.cluster_role_arn

  ####################################################
  # IRSA
  ####################################################

  enable_irsa = true

  ####################################################
  # Cluster Addons
  ####################################################

  cluster_addons = {

    coredns = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }

    aws-ebs-csi-driver = {
      most_recent = true
    }

  }

  ####################################################
  # Managed Node Group
  ####################################################

  eks_managed_node_groups = {

    default = {

      create_iam_role = false

      iam_role_arn = var.node_role_arn

      subnet_ids = var.private_subnets

      instance_types = [
        "t3a.small"
      ]

      capacity_type = "ON_DEMAND"

      desired_size = 1
      min_size     = 1
      max_size     = 2

      disk_size = 8

      ami_type = "AL2023_x86_64_STANDARD"

      additional_security_group_ids = [
        var.node_security_group_id
      ]

      labels = {
        Environment = var.environment
      }

      tags = {
        Name = "${local.cluster_name}-node-group"
      }

    }

  }

  tags = local.common_tags

}
