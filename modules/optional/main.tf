# modules/optional/main.tf
# Optional module orchestration for RunsOn - EFS and ECR

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local variables
locals {
  common_tags = merge(
    var.tags,
    {
      Module = "runs-on-optional"
    }
  )
}
