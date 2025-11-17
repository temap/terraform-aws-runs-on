# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial module implementation for RunsOn infrastructure on AWS
- Storage module: S3 buckets for config, cache, and logging with lifecycle policies
- Compute module: EC2 launch templates (Linux/Windows, default/private), IAM roles and instance profiles
- Core module: App Runner service, SQS queues, DynamoDB tables, EventBridge rules and schedulers, SNS topics
- Optional modules: EFS file system and ECR repository support
- VPC connector support for private networking
- Complete example demonstrating module usage with VPC
- Comprehensive variable validation and defaults
- Auto-scaling configuration for App Runner (1-25 instances)
- Cost reporting and alerting infrastructure
- Support for custom tags, encryption, and monitoring
