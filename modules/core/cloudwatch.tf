# modules/core/cloudwatch.tf
# CloudWatch Alarms for RunsOn core module

###########################
# App Runner Daily Budget Alarm
###########################

resource "aws_cloudwatch_metric_alarm" "app_daily_budget" {
  alarm_name          = "${var.stack_name}-app-daily-budget"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ActiveInstances"
  namespace           = "AWS/AppRunner"
  period              = "86400" # 1 day
  statistic           = "Sum"
  threshold           = var.app_alarm_daily_minutes
  alarm_description   = "Alarm when App Runner active instances exceed daily budget"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  
  dimensions = {
    ServiceName = aws_apprunner_service.this.service_name
    ServiceArn  = aws_apprunner_service.this.arn
  }

  tags = merge(
    local.common_tags,
    {
      Name        = "${var.stack_name}-app-daily-budget"
      Environment = var.environment
      AlarmType   = "budget"
    }
  )
}

###########################
# SQS Oldest Message Alarms
###########################

resource "aws_cloudwatch_metric_alarm" "sqs_main_oldest_message" {
  count = var.sqs_queue_oldest_message_threshold_seconds > 0 ? 1 : 0

  alarm_name          = "${var.stack_name}-sqs-main-oldest-message"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = var.sqs_queue_oldest_message_threshold_seconds
  alarm_description   = "Alarm when SQS main queue oldest message exceeds threshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.main.name
  }

  tags = merge(
    local.common_tags,
    {
      Name        = "${var.stack_name}-sqs-main-oldest-message"
      Environment = var.environment
      AlarmType   = "sqs-monitoring"
    }
  )
}

# Note: Similar alarms can be created for other queues (jobs, termination, etc.) 
# following the same pattern if required for full parity.
