# modules/optional/ecr.tf
# ECR repository for ephemeral Docker image storage

###########################
# ECR Repository
###########################

resource "aws_ecr_repository" "ephemeral" {
  count = var.enable_ecr ? 1 : 0

  name                 = "${var.stack_name}-ephemeral-registry"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    local.common_tags,
    {
      Name        = "${var.stack_name}-ephemeral-registry"
      Environment = var.environment
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

###########################
# ECR Lifecycle Policy
###########################

resource "aws_ecr_lifecycle_policy" "ephemeral" {
  count = var.enable_ecr ? 1 : 0

  repository = aws_ecr_repository.ephemeral[0].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
