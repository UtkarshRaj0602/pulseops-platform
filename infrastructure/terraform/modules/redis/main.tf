resource "aws_elasticache_subnet_group" "redis" {

  name = "${local.name_prefix}-redis-subnet-group"

  subnet_ids = var.private_subnets

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-redis-subnet-group"
    }
  )
}


resource "aws_elasticache_cluster" "redis" {

  cluster_id = "${local.name_prefix}-redis"

  engine = "redis"

  engine_version = var.engine_version

  node_type = var.node_type

  num_cache_nodes = 1

  port = 6379

  subnet_group_name = aws_elasticache_subnet_group.redis.name

  security_group_ids = [
    var.security_group_id
  ]

  apply_immediately = true

  auto_minor_version_upgrade = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-redis"
    }
  )
}
