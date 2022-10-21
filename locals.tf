locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  
  # Frontend
  static_resources        = "frontend"

  # AWS VPC Configuration
  aws_vpc_network         = "10.0.0.0/16"
  aws_az_count            = 2
}