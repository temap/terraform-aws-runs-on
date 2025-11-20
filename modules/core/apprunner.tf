# modules/core/apprunner.tf
# App Runner service for RunsOn core module

###########################
# App Runner Auto Scaling Configuration
###########################

resource "aws_apprunner_auto_scaling_configuration_version" "this" {
  auto_scaling_configuration_name = "${var.stack_name}-autoscaling"
  max_concurrency                 = 100
  max_size                        = 25
  min_size                        = 1

  tags = merge(
    local.common_tags,
    {
      Name        = "${var.stack_name}-autoscaling"
      Environment = var.environment
    }
  )
}

###########################
# App Runner VPC Connector (for private networking)
###########################

resource "aws_apprunner_vpc_connector" "this" {
  count = var.private_mode != "false" ? 1 : 0

  vpc_connector_name = "${var.stack_name}-vpc-connector"
  subnets            = var.private_subnet_ids
  security_groups    = var.security_group_ids

  tags = merge(
    local.common_tags,
    {
      Name        = "${var.stack_name}-vpc-connector"
      Environment = var.environment
    }
  )
}

###########################
# App Runner IAM Role
###########################

resource "aws_iam_role" "apprunner" {
  name = "${var.stack_name}-apprunner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "tasks.apprunner.amazonaws.com",
            "build.apprunner.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name        = "${var.stack_name}-apprunner-role"
      Environment = var.environment
    }
  )
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr" {
  role       = aws_iam_role.apprunner.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# App Runner service policy
resource "aws_iam_role_policy" "apprunner_permissions" {
  name = "AppRunnerPermissions"
  role = aws_iam_role.apprunner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeImages",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeTags",
          "ec2:CreateTags",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSpotInstanceRequests",
          "ec2:RequestSpotInstances",
          "ec2:CancelSpotInstanceRequests"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        Condition = {
          StringEquals = {
            "ec2:CreateAction" = [
              "RunInstances",
              "CreateVolume",
              "CreateSnapshot"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:DescribeStacks",
          "cloudformation:GetTemplate"
        ]
        Resource = "arn:aws:cloudformation:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stack/${var.stack_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = var.ec2_instance_role_arn
      },
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetInstanceProfile"
        ]
        Resource = [
          var.ec2_instance_role_arn,
          var.ec2_instance_profile_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.config_bucket_arn,
          "${var.config_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.cache_bucket_arn,
          "${var.cache_bucket_arn}/runners/*",
          "${var.cache_bucket_arn}/agents/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.alerts.arn
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = [
          aws_sqs_queue.main.arn,
          aws_sqs_queue.jobs.arn,
          aws_sqs_queue.github.arn,
          aws_sqs_queue.pool.arn,
          aws_sqs_queue.housekeeping.arn,
          aws_sqs_queue.termination.arn,
          aws_sqs_queue.events.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.locks.arn,
          aws_dynamodb_table.workflow_jobs.arn,
          "${aws_dynamodb_table.workflow_jobs.arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "RunsOn"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage",
          "ce:UpdateCostAllocationTagsStatus",
          "cloudtrail:LookupEvents",
          "cloudwatch:GetMetricData",
          "cloudwatch:DescribeAlarms",
          "sns:ListSubscriptionsByTopic",
          "ec2:DescribeRouteTables",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "spot.amazonaws.com"
          }
        }
      }
    ]
  })
}

###########################
# App Runner Service
###########################

resource "aws_apprunner_service" "this" {
  service_name = var.stack_name

  instance_configuration {
    cpu               = var.app_cpu
    memory            = var.app_memory
    instance_role_arn = aws_iam_role.apprunner.arn
  }

  network_configuration {
    egress_configuration {
      egress_type       = var.private_mode != "false" ? "VPC" : "DEFAULT"
      vpc_connector_arn = var.private_mode != "false" ? aws_apprunner_vpc_connector.this[0].arn : null
    }

    ingress_configuration {
      is_publicly_accessible = true
    }

    ip_address_type = "IPV4"
  }

  health_check_configuration {
    path                = "/ping"
    protocol            = "HTTP"
    healthy_threshold   = 1
    unhealthy_threshold = 10
    interval            = 3
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.this.arn

  source_configuration {
    image_repository {
      image_configuration {
        port = "8080"

        # All environment variables including private launch templates
        runtime_environment_variables = merge(
          local.base_env_vars,
          {
            RUNS_ON_LAUNCH_TEMPLATE_LINUX_PRIVATE   = var.launch_template_linux_private_id
            RUNS_ON_LAUNCH_TEMPLATE_WINDOWS_PRIVATE = var.launch_template_windows_private_id
          }
        )
      }

      image_identifier      = var.app_image
      image_repository_type = "ECR_PUBLIC"
    }

    auto_deployments_enabled = false
  }

  tags = merge(
    local.common_tags,
    {
      Name        = var.stack_name
      Environment = var.environment
      Service     = "apprunner"
    }
  )
}
