# Copy this file to terraform.tfvars and update with your values

aws_region         = "us-east-1"
project_name       = "cost-tracker"
cost_threshold     = 8.00
notification_email = "queenbassee@gmail.com"
schedule_expression = "rate(7 hours)"
environment        = "dev"