terraform {
  required_version = "~> 1.3.0"

  backend "s3" {
    key     = "state"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  app_domain          = var.base_domain

  s3_origin_id        = "static-site"
  api_origin_id       = "api-gateway"
}

module "certificate" {
  source = "./modules/certificate"

  base_domain = var.base_domain
  app_domain  = local.app_domain
}

resource "aws_cloudfront_origin_access_identity" "cdn" {
  comment = local.s3_origin_id
}

module "static_site" {
  source = "./modules/static_site"

  src               = local.static_resources
  bucket_access_OAI = [aws_cloudfront_origin_access_identity.cdn.iam_arn]
}

module "cdn" {
  source = "./modules/cdn"

  OAI                   = aws_cloudfront_origin_access_identity.cdn
  s3_origin_id          = local.s3_origin_id
  api_origin_id         = local.api_origin_id
  api_domain_name       = module.api_gateway.domain_name
  bucket_domain_name    = module.static_site.domain_name
  aliases               = ["www.${local.app_domain}", local.app_domain]
  certificate_arn       = module.certificate.arn
}

module "dns" {
  source = "./modules/dns"

  base_domain                   = var.base_domain
  app_domain                    = local.app_domain
  app_primary_health_check_path = "/api/time"
  cdn                           = module.cdn.cloudfront_distribution
}

module "vpc" {
    source = "./modules/vpc"

    cidr_block  = local.aws_vpc_network
    zones_count = local.aws_az_count
}

module "api_gateway" {
  source = "./modules/api_gateway"

  aws_region      = var.aws_region
  aws_account_id  = local.aws_account_id
  base_domain     = var.base_domain
  cloudfront_dist = module.cdn.cloudfront_distribution
  lambda          = module.lambda.function
  # api_key_id = aws_api_gateway_api_key.api.id
}

module "lambda" {
  source = "./modules/lambda"

  function_name       = "test"
  filename            = "./lambda/test.zip"
  handler             = "test.handler"
  runtime             = "nodejs12.x"

  subnet_ids = module.vpc.private_subnets_ids
  vpc_id     = module.vpc.vpc_id
  tags = {
    Name = "Test Lambda"
  }
}

module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "job-searchs"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "N"
    },
    {
      name = "description"
      type = "S"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}
