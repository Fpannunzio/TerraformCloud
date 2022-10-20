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