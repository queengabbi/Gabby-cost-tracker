# DynamoDB table for cost logging
resource "aws_dynamodb_table" "cost_tracker" {
  name           = "CostTrackerLogs"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}