# Development Guide

## Prerequisites

Install development tools (macOS):
```bash
make install-tools
```

Or manually install: `opentofu`, `tflint`, `tfsec`, `checkov`, `terraform-docs`

## Development Workflow

### Quick Checks
```bash
make quick       # fmt-check + validate + lint (~20 sec)
make pre-commit  # quick + security scans
```

### Individual Commands
```bash
make fmt         # Format all .tf files
make validate    # Validate OpenTofu syntax
make lint        # Run TFLint
make security    # Run checkov + tfsec
make docs        # Regenerate module READMEs
```

### Watch Mode
```bash
make watch       # Auto-run quick checks on file changes (requires watchexec)
```

## Testing

Tests use [Terratest](https://terratest.gruntwork.io/) and deploy real AWS infrastructure.

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `AWS_ACCESS_KEY_ID` | Yes | AWS credentials |
| `AWS_SECRET_ACCESS_KEY` | Yes | AWS credentials |
| `RUNS_ON_LICENSE_KEY` | Yes | RunsOn license key |
| `AWS_REGION` | No | Defaults to `us-east-1` |
| `GITHUB_ORG` | No | GitHub org for tests |
| `RUNS_ON_TEST_REPO` | No | For integration tests (`owner/repo` format) |
| `GITHUB_TOKEN` | No | For integration tests |

### Running Tests

```bash
cd test

# Run a specific scenario
go test -v -timeout 45m -run "TestScenarioBasic" ./...

# Skip expensive tests (NAT gateway, etc.)
go test -v -short ./...
```

### Test Scenarios

| Test | Description | Cost |
|------|-------------|------|
| `TestScenarioBasic` | Standard deployment | Low |
| `TestScenarioEFSEnabled` | With EFS shared storage | Low |
| `TestScenarioECREnabled` | With ECR registry | Low |
| `TestScenarioPrivateNetworking` | With NAT gateway | High (NAT) |
| `TestScenarioFullFeatured` | All features enabled | High (NAT + EFS + ECR) |

### Test Structure

Each scenario test:
1. Deploys a VPC fixture (`test/fixtures/vpc/`)
2. Deploys the runs-on root module
3. Runs validations:
   - **Output validations** - Check expected outputs exist
   - **Security validations** - S3 encryption, public access blocking, IAM permissions
   - **Compliance validations** - Versioning, log retention
   - **Functional validations** - Launch EC2, verify S3/EFS/ECR access via SSM
4. Cleans up (deferred destroy)

### Test Helpers

Key files in `test/`:
- `scenarios_test.go` - Test scenarios
- `helpers.go` - AWS SDK helpers, validation functions, SSM command execution

Validation functions available:
- `ValidateS3BucketEncryption()` - Verify KMS encryption
- `ValidateS3BucketPublicAccessBlocked()` - Verify public access is blocked
- `ValidateIAMRoleNotOverlyPermissive()` - Check for dangerous policies
- `ValidateS3AccessFromEC2()` - Verify IAM permissions from an EC2 instance
- `ValidateEFSMountFromEC2()` - Mount and test EFS
- `ValidateECRPushPullFromEC2()` - Test Docker buildx cache with ECR

## Cleanup

```bash
make clean  # Remove .terraform, tfstate, tfplan files
```
