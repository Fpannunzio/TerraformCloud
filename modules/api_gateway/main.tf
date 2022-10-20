# API GATEWAY
resource "aws_api_gateway_rest_api" "this" {
  name = "main"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# PATH /test
resource "aws_api_gateway_resource" "test" {
  path_part   = "test"
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.this.id
}

# PATH /test - GET method
resource "aws_api_gateway_method" "test_GET" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.test.id
  http_method   = "GET"
  authorization = "NONE"
}

# PATH /test - GET method INTEGRATION
resource "aws_api_gateway_integration" "lambda_response" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.test.id
  http_method             = aws_api_gateway_method.test_GET.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.lambda.invoke_arn
}


# PATH /test 200 RESPONSE
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.test.id
  http_method = aws_api_gateway_method.test_GET.http_method
  status_code = "200"
}

# PATH /test - GET method - 200 RESPONSE INTEGRATION
resource "aws_api_gateway_integration_response" "lambda_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.test.id
  http_method = aws_api_gateway_method.test_GET.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  depends_on = [
    aws_api_gateway_integration.lambda_response
  ]
}


# DEPLOYMENT
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.test,
      aws_api_gateway_method.test_GET,
      aws_api_gateway_integration.lambda_response,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# PROD STAGE
resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "api"
}

# LAMBDA INVOCATION PERMISSION
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = local.lambda_source_arn
}

