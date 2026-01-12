terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key        = var.kms_key_id
  }

  tags = merge(
    var.tags,
    {
      Name        = var.repository_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      # Production images - keep forever
      {
        rulePriority = 1
        description  = "Keep production images forever"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 999999
        }
        action = {
          type = "expire"
        }
      },
      # Staging images
      {
        rulePriority = 2
        description  = "Keep staging images - last ${var.retention_rules.staging.count} or ${var.retention_rules.staging.days} days"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["*-stg*", "*-staging*"]
          countType      = "imageCountMoreThan"
          countNumber    = var.retention_rules.staging.count
        }
        action = {
          type = "expire"
        }
      },
      # Development images
      {
        rulePriority = 3
        description  = "Keep dev images - last ${var.retention_rules.dev.count} or ${var.retention_rules.dev.days} days"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["*-dev*"]
          countType      = "imageCountMoreThan"
          countNumber    = var.retention_rules.dev.count
        }
        action = {
          type = "expire"
        }
      },
      # Untagged images
      {
        rulePriority = 10
        description  = "Delete untagged images after 1 day"
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

resource "aws_ecr_repository_policy" "this" {
  count      = length(var.allowed_account_ids) > 0 ? 1 : 0
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = [for account_id in var.allowed_account_ids : "arn:aws:iam::${account_id}:root"]
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}