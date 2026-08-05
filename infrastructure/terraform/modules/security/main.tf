resource "aws_security_group" "alb" {

  name        = "${local.name_prefix}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-alb-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {

  security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"

  from_port = 443
  to_port   = 443

  cidr_ipv4 = "0.0.0.0/0"

  description = "HTTPS"
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {

  security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"

  from_port = 80
  to_port   = 80

  cidr_ipv4 = "0.0.0.0/0"

  description = "HTTP"
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {

  security_group_id = aws_security_group.alb.id

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"

}

resource "aws_security_group" "eks_nodes" {

  name = "${local.name_prefix}-eks-node-sg"

  description = "EKS Worker Nodes"

  vpc_id = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-node-sg"
    }
  )
}

resource "aws_security_group" "rds" {

  name = "${local.name_prefix}-rds-sg"

  description = "RDS PostgreSQL"

  vpc_id = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-rds-sg"
    }
  )
}


resource "aws_vpc_security_group_ingress_rule" "rds" {

  security_group_id = aws_security_group.rds.id

  referenced_security_group_id = aws_security_group.eks_nodes.id

  ip_protocol = "tcp"

  from_port = 5432
  to_port   = 5432

  description = "PostgreSQL"
}

resource "aws_vpc_security_group_egress_rule" "rds" {

  security_group_id = aws_security_group.rds.id

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"
}


resource "aws_security_group" "redis" {

  name = "${local.name_prefix}-redis-sg"

  description = "Redis"

  vpc_id = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-redis-sg"
    }
  )
}


resource "aws_vpc_security_group_ingress_rule" "redis" {

  security_group_id = aws_security_group.redis.id

  referenced_security_group_id = aws_security_group.eks_nodes.id

  ip_protocol = "tcp"

  from_port = 6379
  to_port   = 6379

  description = "Redis"
}

resource "aws_vpc_security_group_egress_rule" "redis" {

  security_group_id = aws_security_group.redis.id

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"
}
