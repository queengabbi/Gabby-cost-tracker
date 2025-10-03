# Cloud Cost Tracker & Alert System - Architecture

## System Overview
This is a complete AWS-based cost tracking and alerting system built entirely with Terraform (Infrastructure as Code).

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                AWS Cloud                                        │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐             │
│  │   CloudWatch    │    │   EventBridge   │    │   SNS Topic     │             │
│  │   Billing       │    │   (Schedule)    │    │   (Alerts)      │             │
│  │   Metrics       │    │                 │    │                 │             │
│  └─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘             │
│            │                      │                      │                     │
│            │                      │                      │                     │
│            ▼                      ▼                      │                     │
│  ┌─────────────────┐    ┌─────────────────┐              │                     │
│  │   CloudWatch    │    │   Lambda        │              │                     │
│  │   Alarm         │────┤   Function      │              │                     │
│  │   (Threshold)   │    │   (Cost Logger) │              │                     │
│  └─────────────────┘    └─────────┬───────┘              │                     │
│                                   │                      │                     │
│                                   ▼                      │                     │
│                            ┌─────────────────┐           │                     │
│                            │   DynamoDB      │           │                     │
│                            │   Table         │           │                     │
│                            │   (Cost Data)   │           │                     │
│                            └─────────┬───────┘           │                     │
│                                      │                  │                     │
│                                      │                  │                     │
│                                      ▼                  │                     │
│                            ┌─────────────────┐           │                     │
│                            │   Lambda        │           │                     │
│                            │   Function      │───────────┘                     │
│                            │   (API Handler) │                                 │
│                            └─────────┬───────┘                                 │
│                                      │                                         │
│                                      ▼                                         │
│                            ┌─────────────────┐                                 │
│                            │   API Gateway   │                                 │
│                            │   (REST API)    │                                 │
│                            └─────────┬───────┘                                 │
│                                      │                                         │
│                                      │                                         │
│                                      ▼                                         │
│                            ┌─────────────────┐                                 │
│                            │   CloudFront    │                                 │
│                            │   Distribution  │                                 │
│                            └─────────┬───────┘                                 │
│                                      │                                         │
│                                      ▼                                         │
│                            ┌─────────────────┐                                 │
│                            │   S3 Bucket     │                                 │
│                            │   (Static Site) │                                 │
│                            └─────────────────┘                                 │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
                            ┌─────────────────┐
                            │   End Users     │
                            │   (Web Browser) │
                            └─────────────────┘
```

## Component Details

### 1. **Data Collection Layer**
- **CloudWatch Billing Metrics**: Monitors AWS estimated charges
- **EventBridge Rule**: Triggers cost logging every 6 hours
- **Lambda Function (Cost Logger)**: Fetches billing data and stores in DynamoDB

### 2. **Data Storage Layer**
- **DynamoDB Table**: Stores cost data with TTL for automatic cleanup
- **Primary Key**: `id` (unique identifier for each cost entry)
- **TTL**: 90 days automatic expiration

### 3. **Alerting Layer**
- **CloudWatch Alarm**: Monitors billing threshold
- **SNS Topic**: Sends email notifications when threshold is exceeded
- **Configurable Threshold**: Set via Terraform variables

### 4. **API Layer**
- **API Gateway**: RESTful API for cost data retrieval
- **Lambda Function (API Handler)**: Processes API requests and returns formatted data
- **CORS Support**: Enables cross-origin requests from frontend

### 5. **Frontend Layer**
- **S3 Bucket**: Hosts static website files
- **CloudFront**: CDN for global distribution and caching
- **HTML/JavaScript**: Interactive dashboard with Chart.js

## Data Flow

1. **Cost Collection**:
   - EventBridge triggers Lambda every 6 hours
   - Lambda queries CloudWatch billing metrics
   - Cost data stored in DynamoDB with TTL

2. **Alerting**:
   - CloudWatch alarm monitors billing threshold
   - SNS sends email when threshold exceeded

3. **Data Retrieval**:
   - Frontend requests data via API Gateway
   - API Lambda queries DynamoDB
   - Formatted data returned to frontend

4. **Visualization**:
   - Frontend displays cost trends and summaries
   - Chart.js renders interactive graphs
   - Auto-refresh every 6 hours

## Security Features

- **IAM Roles**: Least privilege access for Lambda functions
- **S3 Private**: Bucket not publicly accessible
- **CloudFront OAI**: Secure access to S3 content
- **API Gateway**: Controlled access to cost data

## Scalability Features

- **DynamoDB**: Auto-scaling based on demand
- **Lambda**: Serverless, scales automatically
- **CloudFront**: Global CDN for fast access
- **S3**: Unlimited storage capacity

## Monitoring & Observability

- **CloudWatch Logs**: Lambda function logs
- **CloudWatch Metrics**: Custom billing metrics
- **DynamoDB Metrics**: Table performance monitoring
- **API Gateway Logs**: Request/response logging


