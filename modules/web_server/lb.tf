resource "aws_lb" "web" {
  name               = "web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_lb.id]
  subnets            = var.public_subnets

  enable_deletion_protection = false
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_target_group" "web" {
  name     = "web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "web_server" {
  count             = length(var.private_subnets)
  target_group_arn  = aws_lb_target_group.web.arn
  target_id         = aws_instance.web_server[count.index].id
  port              = 80
}
