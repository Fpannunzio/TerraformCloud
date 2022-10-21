resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "vpc_attaching" {
  name        = "vpc_attaching"
  path        = "/"
  description = "IAM policy for vpc_attaching a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vpc_attaching" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.vpc_attaching.arn
}

resource "aws_lambda_function" "this" {
  filename = var.filename

  function_name    = var.function_name
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = var.handler
  source_code_hash = filebase64sha256(var.filename)

  runtime = var.runtime

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = var.tags
}

# LAMBDA INVOCATION PERMISSION
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = local.lambda_source_arn
}

# /path
resource "aws_api_gateway_resource" "this" {
  path_part   = var.path_part
  parent_id   = var.gateway_resource_id
  rest_api_id = var.gateway_id
}

# PATH /path - define method
resource "aws_api_gateway_method" "this" {
  rest_api_id   = var.gateway_id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = var.http_method
  authorization = "NONE"
}

# PATH /test - Definir la lambda
resource "aws_api_gateway_integration" "lambda_response" {
  rest_api_id             = var.gateway_id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST" //Lambdas solo pueden ser accedidas por POST
  type                    = "AWS"
  uri                     = aws_lambda_function.this.invoke_arn
}


# PATH /path 200 RESPONSE
resource "aws_api_gateway_method_response" "response" {
  rest_api_id = var.gateway_id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = var.status_code
}

# PATH /path - GET method - 200 RESPONSE INTEGRATION
resource "aws_api_gateway_integration_response" "lambda_response" {
  rest_api_id = var.gateway_id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = aws_api_gateway_method_response.response.status_code

  depends_on = [
    aws_api_gateway_integration.lambda_response
  ]
}