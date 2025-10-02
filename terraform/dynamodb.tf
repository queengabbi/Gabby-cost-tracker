# DynamoDB table for cost logging
resource "aws_dynamodb_table" "cost_tracker" {
  name           = "cloud-cost-tracker"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  range_key      = "timestamp"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled       = true
  }
}