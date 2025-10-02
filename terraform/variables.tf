variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "billing_threshold" {
  description = "The threshold in USD for billing alarms"
  type        = number
  default     = 10
}

variable "notification_email" {
  description = "Email address to receive cost alerts"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}