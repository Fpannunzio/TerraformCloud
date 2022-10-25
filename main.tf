terraform {
  required_version = "~> 1.3.0"

  backend "s3" {
    key     = "state"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.23.0"
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
  bucket_domain_name    = module.static_site.domain_name
  api_origin_id         = local.api_origin_id
  api_domain_name       = module.api_gateway.domain_name
  aliases               = ["www.${local.app_domain}", local.app_domain]
  certificate_arn       = module.certificate.arn
}

module "dns" {
  source = "./modules/dns"

  base_domain                   = var.base_domain
  app_domain                    = local.app_domain
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
  
  
  lambda_hashes   = [module.lambda.lambda_rest_configuration_hash]

}

module "lambda" {
  source = "./modules/lambda"

  function_name       = "test"
  filename            = "./lambda/test.zip"
  handler             = "test.handler"
  runtime             = "nodejs12.x"

  base_domain         = var.base_domain
  aws_account_id      = local.aws_account_id 
  aws_region          = var.aws_region 

  gateway_id          = module.api_gateway.id
  gateway_resource_id = module.api_gateway.resource_id

  path_part           = "test"
  http_method         = "GET"
  status_code         = "200"

  subnet_ids          = module.vpc.private_subnets_ids
  vpc_id              = module.vpc.vpc_id
  tags = {
    Name = "Test Lambda"
  }
}

module "lambda" {
  source = "./modules/lambda"

  function_name       = "listar_busquedas"
  filename            = "./lambda/listar_busquedas.zip"
  handler             = "listar_busquedas.handler"
  runtime             = "nodejs12.x"

  base_domain         = var.base_domain
  aws_account_id      = local.aws_account_id 
  aws_region          = var.aws_region 

  gateway_id          = module.api_gateway.id
  gateway_resource_id = module.api_gateway.resource_id

  path_part           = "listar_busquedas"
  http_method         = "GET"
  status_code         = "200"

  subnet_ids          = module.vpc.private_subnets_ids
  vpc_id              = module.vpc.vpc_id
  tags = {
    Name = "ListarBusquedas Lambda"
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
    }
    ,{
      name = "description"
      type = "S"
    }
  ]

  global_secondary_indexes = [{
    name               = "DescriptionIndex"
    hash_key           = "description"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["id"]
  }]

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}
