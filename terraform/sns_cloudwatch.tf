# SNS Topic for cost alerts
resource "aws_sns_topic" "cost_alerts" {
  name = "cloud-cost-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# CloudWatch Billing Alarm
resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name          = "billing-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period             = "21600" # 6 hours
  statistic          = "Maximum"
  threshold          = var.billing_threshold
  alarm_description  = "Billing alarm when charges exceed ${var.billing_threshold} USD"
  alarm_actions      = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    Currency = "USD"
  }
}

# Enable AWS billing alerts
resource "aws_cloudwatch_metric_alarm" "billing_alerts_enabled" {
  alarm_name          = "billing-alerts-enabled"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period             = "21600"
  statistic          = "Maximum"
  threshold          = 0
  alarm_description  = "Enable billing alerts"

  dimensions = {
    Currency = "USD"
  }
}