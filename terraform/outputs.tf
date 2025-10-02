output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_stage.api.invoke_url}/costs"
}

output "cloudfront_url" {
  description = "CloudFront URL for the website"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "s3_bucket" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for cost alerts"
  value       = aws_sns_topic.cost_alerts.arn
}