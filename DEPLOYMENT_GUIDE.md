# Cloud Cost Tracker - Deployment Guide

## What We Fixed

The original project had several critical issues that have now been resolved:

### ❌ **Issues Found:**
1. **API Gateway Integration**: Was using wrong Lambda function (cost logger instead of API handler)
2. **Missing API Lambda**: No separate function to handle API requests and return data
3. **DynamoDB Schema**: Had both `id` and `timestamp` as keys, causing conflicts
4. **Missing S3 Upload**: Frontend files weren't being uploaded to S3
5. **Lambda Logic**: Cost logger only logged data, couldn't retrieve it for API

### ✅ **Fixes Applied:**
1. **Fixed DynamoDB Schema**: Now uses single primary key (`id`) only
2. **Created API Lambda**: New `lambda/cost_api/` function to handle API requests
3. **Updated API Gateway**: Now correctly points to the API Lambda function
4. **Added S3 Upload**: Frontend files automatically uploaded during deployment
5. **Enhanced Frontend**: Better error handling and chart rendering
6. **Improved Data Flow**: Proper separation of concerns between logging and API

## Deployment Instructions

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform installed (>= 1.0)
- Python 3.9+ (for Lambda functions)

### Step 1: Configure Variables
Update `terraform.tfvars` with your values:
```hcl
aws_region         = "us-east-1"  # Your preferred region
project_name       = "cost-tracker"
cost_threshold     = 10.00        # Your spending threshold
notification_email = "your-email@example.com"
schedule_expression = "rate(6 hours)"
environment        = "dev"
```

### Step 2: Deploy Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Step 3: Verify Deployment
1. **Check API Endpoint**: Test the API Gateway URL
2. **Verify S3 Upload**: Check that frontend files are in S3
3. **Test CloudFront**: Access the dashboard via CloudFront URL
4. **Monitor Lambda**: Check CloudWatch logs for both Lambda functions

## Testing the System

### Manual Testing
1. **Trigger Cost Logger**: Manually invoke the cost logger Lambda
2. **Check DynamoDB**: Verify data is being stored
3. **Test API**: Call the API Gateway endpoint
4. **View Dashboard**: Open the CloudFront URL

### Lower Threshold for Testing
To see alerts quickly, temporarily lower the billing threshold:
```hcl
cost_threshold = 0.01  # $0.01 threshold for testing
```

## Architecture Overview

The system now follows a proper microservices architecture:

```
CloudWatch Metrics → EventBridge → Cost Logger Lambda → DynamoDB
                                                           ↓
Frontend (S3/CloudFront) ← API Gateway ← API Lambda ←─────┘
```

## Key Features

- **Automated Cost Logging**: Every 6 hours via EventBridge
- **Real-time Alerts**: SNS notifications when threshold exceeded
- **Interactive Dashboard**: Chart.js visualization with auto-refresh
- **Scalable Architecture**: Serverless components that scale automatically
- **Secure Access**: CloudFront OAI for secure S3 access

## Monitoring

- **CloudWatch Logs**: Both Lambda functions log to CloudWatch
- **DynamoDB Metrics**: Monitor table performance
- **API Gateway Logs**: Track API usage and errors
- **SNS Notifications**: Email alerts for cost threshold breaches

## Next Steps

1. Deploy the updated infrastructure
2. Test all components
3. Monitor for any issues
4. Customize the dashboard as needed
5. Set up additional monitoring/alerting if required


