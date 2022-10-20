locals {
  private_cidr = cidrsubnet(aws_vpc.main.cidr_block, 1, 1)
}