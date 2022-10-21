resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name

  tags = {
    Name = "main"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count             = var.zones_count
  cidr_block        = cidrsubnet(local.private_cidr, ceil(log(var.zones_count, 2)), count.index)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private_${count.index}"
  }
}
