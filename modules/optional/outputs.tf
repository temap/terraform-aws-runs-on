# modules/optional/outputs.tf
# Output values from the optional module

###########################
# EFS Outputs
###########################

output "efs_file_system_id" {
  description = "ID of the EFS file system (if enabled)"
  value       = var.enable_efs ? aws_efs_file_system.this[0].id : null
}

output "efs_file_system_arn" {
  description = "ARN of the EFS file system (if enabled)"
  value       = var.enable_efs ? aws_efs_file_system.this[0].arn : null
}

output "efs_file_system_dns_name" {
  description = "DNS name of the EFS file system (if enabled)"
  value       = var.enable_efs ? aws_efs_file_system.this[0].dns_name : null
}

output "efs_security_group_id" {
  description = "ID of the EFS security group (if enabled)"
  value       = var.enable_efs ? aws_security_group.efs[0].id : null
}

###########################
# ECR Outputs
###########################

output "ecr_repository_arn" {
  description = "ARN of the ECR repository (if enabled)"
  value       = var.enable_ecr ? aws_ecr_repository.ephemeral[0].arn : null
}

output "ecr_repository_url" {
  description = "URL of the ECR repository (if enabled)"
  value       = var.enable_ecr ? aws_ecr_repository.ephemeral[0].repository_url : null
}

output "ecr_repository_name" {
  description = "Name of the ECR repository (if enabled)"
  value       = var.enable_ecr ? aws_ecr_repository.ephemeral[0].name : null
}
