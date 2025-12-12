# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenTofu/Terraform module for deploying [RunsOn](https://runs-on.com) self-hosted GitHub Actions runners on AWS. The module orchestrates App Runner, S3 buckets, SQS queues, DynamoDB tables, IAM roles, and EC2 launch templates.

## Common Commands

### Development
```bash
make init           # Initialize OpenTofu
make validate       # Validate OpenTofu syntax
make fmt            # Format OpenTofu files
make fmt-check      # Check formatting
make lint           # Run TFLint
make security       # Run checkov and tfsec security scans
make quick          # Run all fast checks (fmt-check, validate, lint)
make pre-commit     # Run before committing (quick + security)
make docs           # Generate terraform-docs for all modules
```

### Testing
Tests use Terratest (Go) and deploy real AWS infrastructure.
```bash
cd test
go test -v -timeout 45m -run "TestScenarioBasic" ./...     # Basic scenario
go test -v -timeout 60m -run "TestScenarioEFSEnabled" ./... # EFS scenario
go test -v -timeout 60m -run "TestScenarioECREnabled" ./... # ECR scenario
go test -v -short ./...                                     # Skip expensive tests
```

Environment variables for tests:
- `RUNS_ON_LICENSE_KEY` - Required for tests
- `AWS_REGION` - Defaults to us-east-1
- `GITHUB_ORG` or `RUNS_ON_TEST_REPO` - For integration tests

### OpenTofu Operations
```bash
tofu init -upgrade
tofu plan -out=tfplan
tofu apply tfplan
```

## Module Architecture

```
.
├── main.tf              # Root module - orchestrates submodules
├── variables.tf         # Root module inputs
├── outputs.tf           # Root module outputs
├── security_groups.tf   # Runner security groups
└── modules/
    ├── core/            # App Runner, SQS, DynamoDB, SNS, EventBridge
    ├── compute/         # Launch templates, IAM roles, CloudWatch logs
    ├── storage/         # S3 buckets (config, cache, logging)
    └── optional/        # EFS and ECR (disabled by default)
```

### Module Dependencies Flow
```
storage → compute → optional → core
```

The root module coordinates all submodules:
1. **storage** creates S3 buckets first (no dependencies)
2. **compute** needs bucket ARNs for IAM policies
3. **optional** creates EFS/ECR if enabled
4. **core** needs everything: bucket ARNs, IAM roles, launch template IDs

### Key Design Patterns

- **Optional features**: EFS and ECR are controlled by `enable_efs` and `enable_ecr` variables with conditional resource creation
- **Private networking**: Controlled by `private_mode` variable with values: `false`, `true`, `always`, `only`
- **Security groups**: Can be provided externally via `security_group_ids` or created automatically

## Test Structure

Tests in `test/` use Terratest and follow this pattern:
1. Deploy VPC fixture (`test/fixtures/vpc/`)
2. Deploy runs-on root module
3. Run security validations (S3 encryption, IAM permissions, public access blocking)
4. Run compliance validations (versioning, log retention)
5. Run functional validations (launch EC2, verify S3 access via SSM)
6. Cleanup (deferred destroy)

Test scenarios:
- `TestScenarioBasic` - Standard deployment
- `TestScenarioPrivateNetworking` - With NAT gateway (expensive)
- `TestScenarioEFSEnabled` - With EFS
- `TestScenarioECREnabled` - With ECR
- `TestScenarioFullFeatured` - All features (most expensive)

## Important Variables

Required:
- `vpc_id` - VPC where RunsOn deploys
- `public_subnet_ids` - At least one required
- `github_organization` - GitHub org for RunsOn integration
- `license_key` - RunsOn license key

Key optional:
- `enable_efs` / `enable_ecr` - Feature flags
- `private_mode` - Private networking mode
- `private_subnet_ids` - Required if private_mode != "false"
- `force_destroy_buckets` / `force_delete_ecr` - For test cleanup
