resource "random_password" "db_password" {

  length = 24

  special = true

}

resource "aws_secretsmanager_secret" "database" {

  name = "${local.name_prefix}-database"

  recovery_window_in_days = 7

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-database"
    }
  )

}

resource "aws_secretsmanager_secret_version" "database" {

  secret_id = aws_secretsmanager_secret.database.id

  secret_string = jsonencode({

    username = var.db_username

    password = random_password.db_password.result

  })

}

