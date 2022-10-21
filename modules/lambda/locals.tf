locals {
  lambda_source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${var.gateway_id}/*/${aws_api_gateway_method.this.http_method}${aws_api_gateway_resource.this.path}"
}