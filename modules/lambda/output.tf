output "function" {
  description = "The lambda function"
  value       = aws_lambda_function.this
}

output "lambda_rest_configuration_hash" {
  description = "The lambda hash to check if rest configuration has changed"
  value       = sha1(jsonencode([
      aws_api_gateway_resource.this,
      aws_api_gateway_method.this,
      aws_api_gateway_integration.lambda_response,
    ]))
}





