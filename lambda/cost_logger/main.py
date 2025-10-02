import boto3
import json
import os
import uuid
from datetime import datetime, timezone

def lambda_handler(event, context):
    try:
        # Initialize AWS clients
        cloudwatch = boto3.client('cloudwatch')
        dynamodb = boto3.resource('dynamodb').Table(os.environ['DYNAMODB_TABLE'])
        
        # Get billing metrics
        response = cloudwatch.get_metric_statistics(
            Namespace='AWS/Billing',
            MetricName='EstimatedCharges',
            Dimensions=[{'Name': 'Currency', 'Value': 'USD'}],
            StartTime=datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0),
            EndTime=datetime.now(timezone.utc),
            Period=21600,  # 6 hours
            Statistics=['Maximum']
        )
        
        # Process the cost data
        if response['Datapoints']:
            cost_data = {
                'id': str(uuid.uuid4()),
                'timestamp': datetime.now(timezone.utc).isoformat(),
                'cost': response['Datapoints'][0]['Maximum'],
                'ttl': int(datetime.now(timezone.utc).timestamp()) + (90 * 24 * 60 * 60)  # 90 days TTL
            }
            
            # Store in DynamoDB
            dynamodb.put_item(Item=cost_data)
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Cost data logged successfully',
                    'data': cost_data
                })
            }
        else:
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'No cost data available for the period'
                })
            }
            
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error logging cost data',
                'error': str(e)
            })
        }