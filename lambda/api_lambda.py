import boto3
import json
import os

dynamodb = boto3.resource("dynamodb")
table_name = os.environ.get("DDB_TABLE", "CostTrackerLogs")
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    response = table.scan(Limit=10)
    items = response.get("Items", [])
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type"
        },
        "body": json.dumps(items)
    }


