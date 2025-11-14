# modules/storage/main.tf
# Storage module orchestration for RunsOn - S3 buckets for config, cache, and logging

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

# Local variables
locals {
  config_bucket_name  = "${var.stack_name}-config-${data.aws_caller_identity.current.account_id}"
  cache_bucket_name   = "${var.stack_name}-cache-${data.aws_caller_identity.current.account_id}"
  logging_bucket_name = "${var.stack_name}-logging-${data.aws_caller_identity.current.account_id}"

  common_tags = merge(
    var.tags,
    {
      ManagedBy = "opentofu"
      Module    = "runs-on-storage"
    }
  )
}
