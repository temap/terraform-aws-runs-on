# Complete Example: VPC + RunsOn Infrastructure
# This example demonstrates deploying RunsOn with a dedicated VPC

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module - Creates networking infrastructure
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.stack_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  # NAT Gateway for private subnets
  # Only created when user enables private networking (matches CF default: Private="false")
  enable_nat_gateway = var.enable_private_networking
  single_nat_gateway = var.single_nat_gateway # Set to false for HA across AZs

  # Internet connectivity
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags
  tags = {
    Environment = var.environment
    ManagedBy   = "OpenTofu"
    Project     = "RunsOn"
  }

  public_subnet_tags = {
    Type = "public"
  }

  private_subnet_tags = {
    Type = "private"
  }
}

# RunsOn Module - Deploys RunsOn infrastructure
module "runs_on" {
  source = "../../" # Points to root of this repo

  # Stack configuration
  stack_name  = var.stack_name
  aws_region  = var.aws_region
  environment = var.environment

  # Required: GitHub and License
  github_organization = var.github_organization
  license_key         = var.license_key
  email               = var.email

  # Network configuration (BYOV)
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets

  # Security groups will be created automatically if not provided
  security_group_ids = [] # Empty = module creates them

  # Optional features
  enable_efs = var.enable_efs
  enable_ecr = var.enable_ecr

  # SSH access (optional)
  ssh_allowed    = var.ssh_allowed
  ssh_cidr_range = var.ssh_cidr_range
}
