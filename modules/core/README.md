# Core Module

Core orchestration module for RunsOn - manages App Runner service, SQS queues, DynamoDB tables, SNS topics, and EventBridge rules.

## Features

- App Runner service for RunsOn orchestration
- SQS queues for job processing (7 queues)
- DynamoDB tables for locks and workflow job tracking
- SNS topic for alerts and notifications
- EventBridge rules for Spot interruption handling
- Scheduler for automated cost reports
- VPC connector for private networking (optional)
- Slack/Email/HTTPS alert subscriptions (optional)

## Usage

```hcl
module "core" {
  source = "./modules/core"

  stack_name         = "runs-on-prod"
  environment        = "production"
  
  github_organization = "my-org"
  license_key        = var.license_key

  # Networking
  vpc_id             = "vpc-123"
  public_subnet_ids  = ["subnet-abc", "subnet-def"]
  security_group_ids = ["sg-123"]

  # From storage module
  config_bucket_name = module.storage.config_bucket_name
  config_bucket_arn  = module.storage.config_bucket_arn
  cache_bucket_name  = module.storage.cache_bucket_name
  cache_bucket_arn   = module.storage.cache_bucket_arn

  # From compute module
  ec2_instance_role_name           = module.compute.ec2_instance_role_name
  ec2_instance_role_arn            = module.compute.ec2_instance_role_arn
  ec2_instance_profile_arn         = module.compute.ec2_instance_profile_arn
  launch_template_linux_default_id = module.compute.launch_template_linux_default_id
  launch_template_windows_default_id = module.compute.launch_template_windows_default_id

  # Optional: Alerts
  alert_email = "devops@company.com"
}
```

## Components

### App Runner Service
- Orchestrates GitHub Actions runner provisioning
- Processes queue messages
- Manages runner lifecycle
- Auto-scaling configuration

### SQS Queues (7 total)
- **Main Queue**: Primary job processing (FIFO)
- **Jobs Queue**: Workflow job scheduling (FIFO)
- **GitHub Queue**: GitHub registration tasks (FIFO)
- **Pool Queue**: Pool management
- **Housekeeping Queue**: Maintenance tasks
- **Termination Queue**: Runner termination
- **Events Queue**: AWS events (Spot interruptions, scheduled tasks)

### DynamoDB Tables
- **Locks Table**: Distributed locking
- **Workflow Jobs Table**: Job tracking with GSI for queries

### SNS Topics
- **Alerts Topic**: Notifications for errors, warnings, cost reports

### EventBridge Rules
- **Spot Interruption**: Captures EC2 Spot warnings
- **Cost Reports**: Scheduled daily reports (optional)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| stack_name | Stack name | `string` | n/a | yes |
| github_organization | GitHub org/user | `string` | n/a | yes |
| license_key | RunsOn license key | `string` | n/a | yes |
| vpc_id | VPC ID | `string` | n/a | yes |
| public_subnet_ids | Public subnet IDs | `list(string)` | n/a | yes |
| security_group_ids | Security group IDs | `list(string)` | n/a | yes |
| config_bucket_name | Config bucket name | `string` | n/a | yes |
| config_bucket_arn | Config bucket ARN | `string` | n/a | yes |
| cache_bucket_name | Cache bucket name | `string` | n/a | yes |
| cache_bucket_arn | Cache bucket ARN | `string` | n/a | yes |
| ec2_instance_role_name | EC2 role name | `string` | n/a | yes |
| ec2_instance_role_arn | EC2 role ARN | `string` | n/a | yes |
| ec2_instance_profile_arn | EC2 profile ARN | `string` | n/a | yes |
| launch_template_linux_default_id | Linux template ID | `string` | n/a | yes |
| launch_template_windows_default_id | Windows template ID | `string` | n/a | yes |
| app_cpu | CPU units for App Runner | `number` | `1024` | no |
| app_memory | Memory in MB for App Runner | `number` | `2048` | no |
| enable_cost_reports | Enable cost reports | `bool` | `true` | no |
| alert_email | Email for alerts | `string` | `""` | no |
| private_networking_enabled | Enable private networking | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| apprunner_service_url | App Runner service URL |
| apprunner_service_arn | App Runner service ARN |
| sns_topic_arn | SNS alerts topic ARN |
| sqs_queue_main_url | Main queue URL |
| dynamodb_locks_table_name | Locks table name |
| dynamodb_workflow_jobs_table_name | Workflow jobs table name |

## Files

- `main.tf` - Orchestration (terraform, data, locals)
- `apprunner.tf` - App Runner service and IAM
- `sqs.tf` - SQS queues and policies
- `dynamodb.tf` - DynamoDB tables
- `sns.tf` - SNS topics and subscriptions
- `eventbridge.tf` - EventBridge rules and scheduler
- `variables.tf` - Input variables
- `outputs.tf` - Output values