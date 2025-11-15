# Variables for complete example deployment

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "stack_name" {
  description = "Name of the RunsOn stack (must be unique in your account/region)"
  type        = string
  default     = "runs-on-tofu-test"
}

variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "enable_private_networking" {
  description = "Enable private networking with NAT gateway (matches CF 'Private' parameter). Set to true to allow runners in private subnets with static egress IPs."
  type        = bool
  default     = false # Matches CloudFormation default: Private="false"
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets (cheaper but not HA). Only applies if enable_private_networking=true"
  type        = bool
  default     = true # Set to false for multi-AZ high availability
}

# RunsOn Required Configuration
variable "github_organization" {
  description = "GitHub organization or username for RunsOn integration"
  type        = string
}

variable "license_key" {
  description = "RunsOn license key"
  type        = string
  sensitive   = true
}

variable "email" {
  description = "Email address for cost and alert reports"
  type        = string
  default     = ""
}

# RunsOn Optional Features
variable "enable_efs" {
  description = "Enable EFS for shared storage across runners"
  type        = bool
  default     = false
}

variable "enable_ecr" {
  description = "Enable ECR for ephemeral Docker image registry"
  type        = bool
  default     = false
}

# SSH Access Configuration
variable "ssh_allowed" {
  description = "Allow SSH access to runner instances"
  type        = bool
  default     = true
}

variable "ssh_cidr_range" {
  description = "CIDR range allowed for SSH access (default: anywhere)"
  type        = string
  default     = "0.0.0.0/0"
}
