# modules/core/main.tf
# Core module orchestration for RunsOn - App Runner, SQS, DynamoDB, SNS, EventBridge

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
      ManagedBy = "opentofu"
      Module    = "runs-on-core"
    }
  )

  # Queue names
  queue_main         = "${var.stack_name}-main.fifo"
  queue_jobs         = "${var.stack_name}-jobs.fifo"
  queue_github       = "${var.stack_name}-github.fifo"
  queue_pool         = "${var.stack_name}-pool"
  queue_housekeeping = "${var.stack_name}-housekeeping"
  queue_termination  = "${var.stack_name}-termination"
  queue_events       = "${var.stack_name}-events"
}
