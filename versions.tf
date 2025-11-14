# versions.tf
# OpenTofu version constraints and provider configuration

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.tags,
      {
        ManagedBy   = "opentofu"
        Module      = "runs-on"
        StackName   = var.stack_name
        Environment = var.environment
      }
    )
  }
}
