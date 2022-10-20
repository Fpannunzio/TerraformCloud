locals {
  # Application names
  app_name                = "demo"
  pri_app_deploy          = "aws"

  # Frontend
  static_resources        = "frontend"

  # SSH
  ssh_key_name            = "redes_key"

  # AWS VPC Configuration
  aws_vpc_network         = "10.0.0.0/16"
  aws_az_count            = 2
}