locals {
  lambda_source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.this.id}/*/${aws_api_gateway_method.test_GET.http_method}${aws_api_gateway_resource.test.path}"
}