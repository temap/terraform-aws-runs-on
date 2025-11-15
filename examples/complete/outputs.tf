# Outputs from complete example deployment

# VPC Outputs
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "nat_gateway_ids" {
  description = "IDs of NAT Gateways"
  value       = module.vpc.natgw_ids
}

# RunsOn Outputs
output "apprunner_service_url" {
  description = "URL of the RunsOn App Runner service"
  value       = module.runs_on.apprunner_service_url
}

output "config_bucket_name" {
  description = "Name of the configuration S3 bucket"
  value       = module.runs_on.config_bucket_name
}

output "cache_bucket_name" {
  description = "Name of the cache S3 bucket"
  value       = module.runs_on.cache_bucket_name
}

output "dynamodb_locks_table_name" {
  description = "Name of the DynamoDB locks table"
  value       = module.runs_on.dynamodb_locks_table_name
}

output "dynamodb_workflow_jobs_table_name" {
  description = "Name of the DynamoDB workflow jobs table"
  value       = module.runs_on.dynamodb_workflow_jobs_table_name
}

output "sqs_queue_main_url" {
  description = "URL of the main SQS queue"
  value       = module.runs_on.sqs_queue_main_url
}

output "security_group_id" {
  description = "ID of the created security group for runners"
  value       = module.runs_on.security_group_id
}

# Getting Started
output "getting_started" {
  description = "Next steps after deployment"
  value       = <<-EOT

  ========================================
  RunsOn Infrastructure Deployed! 🚀
  ========================================

  Stack Name: ${var.stack_name}
  Region:     ${var.aws_region}
  VPC:        ${module.vpc.vpc_id}

  App Runner Service: ${module.runs_on.apprunner_service_url}

  Next Steps:
  1. Configure GitHub Actions to use this RunsOn installation
  2. Add 'runs-on: [self-hosted, linux, x64]' to your workflow jobs
  3. Monitor via App Runner console or CloudWatch

  Cost Monitoring:
  - Check CloudWatch metrics for usage
  - Review S3 bucket sizes periodically
  - Monitor EC2 instance hours

  For documentation, visit: https://runs-on.com/docs
  EOT
}
