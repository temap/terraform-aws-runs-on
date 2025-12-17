# Development Guide

## Prerequisites

Install development tools (macOS):
```bash
make install-tools
```

Or manually install: `opentofu`, `tflint`, `tfsec`, `terraform-docs`

For tests, install [mise](https://mise.jdx.dev/) to manage Go version:
```bash
cd test && mise install
```

## Development Workflow

### Quick Checks
```bash
make quick       # fmt-check + validate + lint
make pre-commit  # quick + security scan
```

### Individual Commands
```bash
make fmt         # Format all .tf files
make validate    # Validate OpenTofu syntax
make lint        # Run TFLint
make security    # Run tfsec
make docs        # Regenerate module READMEs
```

## Testing

Tests use [Terratest](https://terratest.gruntwork.io/) and deploy real AWS infrastructure. See [test/README.md](test/README.md) for detailed documentation.

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `AWS_ACCESS_KEY_ID` | Yes | AWS credentials |
| `AWS_SECRET_ACCESS_KEY` | Yes | AWS credentials |
| `RUNS_ON_LICENSE_KEY` | Yes | RunsOn license key |
| `AWS_REGION` | No | Defaults to `us-east-1` |
| `RUNS_ON_TEST_REPO` | No | For integration tests (`owner/repo` format) |
| `RUNS_ON_TEST_WORKFLOW` | No | For integration tests (workflow file name) |
| `GITHUB_TOKEN` | No | For integration tests |

### Running Tests

```bash
# Run basic scenario (default)
make test

# Run specific scenarios
make test-basic    # Standard deployment (~$1-2, 30-45 min)
make test-full     # All features: NAT + EFS + ECR (~$3-5, 45-60 min)

# Run all scenarios
make test-all

# Skip expensive scenarios
make test-short
```

### Test Scenarios

| Command | Test | Cost |
|---------|------|------|
| `make test-basic` | `TestScenarioBasic` | Low |
| `make test-full` | `TestScenarioFullFeatured` | High (NAT + EFS + ECR) |

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

## Cleanup

```bash
make clean  # Remove .terraform, tfstate, tfplan files
```
