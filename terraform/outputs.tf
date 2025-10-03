output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_stage.api.invoke_url}/costs"
}

output "website_url" {
  description = "S3 website URL"
  value       = "http://${aws_s3_bucket.website.bucket}.s3-website-${var.aws_region}.amazonaws.com"
}

output "s3_bucket" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for cost alerts"
  value       = aws_sns_topic.cost_alerts.arn
}