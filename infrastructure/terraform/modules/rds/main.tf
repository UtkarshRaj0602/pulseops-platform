resource "aws_db_instance" "postgres" {

  identifier = "${local.name_prefix}-postgres"

  engine = var.engine

  engine_version = var.engine_version

  instance_class = var.instance_class

  allocated_storage = var.allocated_storage

  storage_type = var.storage_type

  storage_encrypted = true

  db_name = var.db_name

  username = var.db_username

  password = var.db_password

  db_subnet_group_name = var.db_subnet_group_name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  publicly_accessible = false

  multi_az = false

  backup_retention_period = 0

  delete_automated_backups = true

  deletion_protection = false

  skip_final_snapshot = true

  performance_insights_enabled = false

  monitoring_interval = 0

  max_allocated_storage = 0

  auto_minor_version_upgrade = true

  apply_immediately = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-postgres"
    }
  )

}
