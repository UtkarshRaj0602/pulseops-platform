resource "aws_ecr_repository" "repositories" {

  for_each = toset(local.repositories)

  name = "${local.name_prefix}-${each.value}"

  image_tag_mutability = "IMMUTABLE"

  force_delete = false

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${each.value}"
    }
  )
}

resource "aws_ecr_lifecycle_policy" "repositories" {

  for_each = aws_ecr_repository.repositories

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1

        description = "Keep latest 10 images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }

        action = {
          type = "expire"
        }
      }
    ]
  })

}
