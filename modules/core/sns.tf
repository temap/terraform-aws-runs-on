# modules/core/sns.tf
# SNS topics for RunsOn core module

###########################
# Alert Topic
###########################

resource "aws_sns_topic" "alerts" {
  name         = "${var.stack_name}-alerts"
  display_name = "RunsOn Alerts"

  tags = merge(
    local.common_tags,
    {
      Name        = "${var.stack_name}-alerts"
      Environment = var.environment
      TopicType   = "alerts"
    }
  )
}

###########################
# Topic Subscriptions (Optional)
###########################

resource "aws_sns_topic_subscription" "email" {
  count = var.email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email
}

resource "aws_sns_topic_subscription" "https" {
  count = var.alert_https_endpoint != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "https"
  endpoint  = var.alert_https_endpoint
}

###########################
# Slack Webhook Lambda (Optional - TODO: Implement)
###########################

# NOTE: Slack Lambda webhook support not yet implemented
# Users can subscribe to the SNS topic manually or use HTTPS endpoint
