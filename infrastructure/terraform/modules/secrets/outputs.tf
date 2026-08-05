output "database_secret_arn" {

  value = aws_secretsmanager_secret.database.arn

}

output "database_secret_name" {

  value = aws_secretsmanager_secret.database.name

}

output "database_username" {

  value = var.db_username

}

output "database_password" {

  value = random_password.db_password.result

  sensitive = true

}
