resource "aws_instance" "web_server" {
  count                     = length(var.private_subnets)
  ami                       = var.ami
  instance_type             = var.instance_type
  key_name                  = var.key_name
  subnet_id                 = var.private_subnets[count.index]
  user_data                 = var.user_data
  vpc_security_group_ids    = [aws_security_group.web.id]

  tags = {
    Name = "web_server_${count.index}"
  }
}