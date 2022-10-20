resource "aws_security_group" "lambda" {
  name   = "lambda"
  vpc_id = var.vpc_id
  tags = {
    Name = "lambda"
  }
}

resource "aws_security_group_rule" "out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda.id
}

resource "aws_security_group_rule" "http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda.id
}

resource "aws_security_group_rule" "https_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda.id
}
