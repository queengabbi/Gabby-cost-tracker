# Lambda function for cost logging
data "archive_file" "lambda_cost_logger" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/cost_logger"
  output_path = "${path.module}/files/cost_logger.zip"
}

resource "aws_lambda_function" "cost_logger" {
  filename         = data.archive_file.lambda_cost_logger.output_path
  function_name    = "cloud-cost-logger"
  role            = aws_iam_role.lambda_role.arn
  handler         = "main.lambda_handler"
  source_code_hash = data.archive_file.lambda_cost_logger.output_base64sha256
  runtime         = "python3.9"
  timeout         = 30

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.cost_tracker.name
    }
  }
}

# EventBridge rule to trigger Lambda on schedule
resource "aws_cloudwatch_event_rule" "cost_logger_schedule" {
  name                = "cost-logger-schedule"
  description         = "Trigger cost logger Lambda function"
  schedule_expression = "rate(6 hours)"
}

resource "aws_cloudwatch_event_target" "cost_logger" {
  rule      = aws_cloudwatch_event_rule.cost_logger_schedule.name
  target_id = "CostLoggerLambda"
  arn       = aws_lambda_function.cost_logger.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_logger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cost_logger_schedule.arn
}

# API Gateway for cost data retrieval
resource "aws_api_gateway_rest_api" "cost_api" {
  name = "cloud-cost-tracker-api"
}

resource "aws_api_gateway_resource" "costs" {
  rest_api_id = aws_api_gateway_rest_api.cost_api.id
  parent_id   = aws_api_gateway_rest_api.cost_api.root_resource_id
  path_part   = "costs"
}

resource "aws_api_gateway_method" "get_costs" {
  rest_api_id   = aws_api_gateway_rest_api.cost_api.id
  resource_id   = aws_api_gateway_resource.costs.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.cost_api.id
  resource_id = aws_api_gateway_resource.costs.id
  http_method = aws_api_gateway_method.get_costs.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.cost_logger.invoke_arn
}

resource "aws_api_gateway_deployment" "api" {
  depends_on = [
    aws_api_gateway_integration.lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.cost_api.id
}

resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id  = aws_api_gateway_rest_api.cost_api.id
  stage_name   = var.environment
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_logger.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.cost_api.execution_arn}/*/*"
}