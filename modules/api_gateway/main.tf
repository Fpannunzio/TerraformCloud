resource "aws_api_gateway_rest_api" "this" {
  name = "main"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
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
    redeployment = sha1(jsonencode(var.lambda_hashes))
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



