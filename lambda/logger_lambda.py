import boto3
import json
import os
from datetime import datetime, timedelta

dynamodb = boto3.resource("dynamodb")
cloudwatch = boto3.client('cloudwatch')
ce = boto3.client('ce')  # Cost Explorer
table_name = os.environ.get("DDB_TABLE", "CostTrackerLogs")
table = dynamodb.Table(table_name)

def get_aws_costs():
    """Fetch real AWS costs from Cost Explorer"""
    try:
        # Get costs for the last 7 days
        end_date = datetime.now()
        start_date = end_date - timedelta(days=7)
        
        response = ce.get_cost_and_usage(
            TimePeriod={
                'Start': start_date.strftime('%Y-%m-%d'),
                'End': end_date.strftime('%Y-%m-%d')
            },
            Granularity='DAILY',
            Metrics=['BlendedCost']
        )
        
        costs = []
        for result in response['ResultsByTime']:
            date = result['TimePeriod']['Start']
            cost = float(result['Total']['BlendedCost']['Amount'])
            costs.append({
                'date': date,
                'cost': cost
            })
        
        return costs
    except Exception as e:
        print(f"Error fetching costs: {e}")
        return []

def get_cloudwatch_billing_metrics():
    """Get billing metrics from CloudWatch"""
    try:
        end_time = datetime.utcnow()
        start_time = end_time - timedelta(days=1)
        
        response = cloudwatch.get_metric_statistics(
            Namespace='AWS/Billing',
            MetricName='EstimatedCharges',
            Dimensions=[
                {
                    'Name': 'Currency',
                    'Value': 'USD'
                }
            ],
            StartTime=start_time,
            EndTime=end_time,
            Period=3600,
            Statistics=['Maximum']
        )
        
        if response['Datapoints']:
            latest_cost = max(response['Datapoints'], key=lambda x: x['Timestamp'])
            return latest_cost['Maximum']
        return 0
    except Exception as e:
        print(f"Error fetching billing metrics: {e}")
        return 0

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))
    timestamp = datetime.utcnow().isoformat()

    # Get real AWS costs
    costs = get_aws_costs()
    current_cost = get_cloudwatch_billing_metrics()
    
    # Create meaningful cost alerts
    if costs:
        latest_cost = costs[-1]['cost']
        message = f"Daily AWS Cost: ${latest_cost:.2f} (Total: ${current_cost:.2f})"
    else:
        message = f"Current AWS Cost: ${current_cost:.2f}"

    table.put_item(Item={
        "id": timestamp,
        "message": message,
        "cost": current_cost,
        "date": timestamp.split('T')[0]
    })

    return {"statusCode": 200, "body": "Real cost data logged"}


