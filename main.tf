terraform {
  required_version = "~> 1.2.0"

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
  # pri_deploy_domain   = "${local.pri_app_deploy}.${var.base_domain}"
  # sec_deploy_domain   = "${local.sec_app_deploy}.${var.base_domain}"

  s3_origin_id        = "static-site"
  # api_origin_id       = "nginx-api"
}

module "certificate" {
  source = "./modules/certificate"

  base_domain = var.base_domain
  app_domain  = local.app_domain
}

# module "vpc" {
#     source = "./aws/modules/vpc"

#     cidr_block  = local.aws_vpc_network
#     zones_count = local.aws_az_count
#     natgw       = true
# }

# resource "aws_key_pair" "redes_key" {
#   key_name   = local.ssh_key_name
#   public_key = file(var.ssh_key_path)
# }

# data "template_file" "web_server_ud" {
#   template = file(local.aws_ec2_web_user_data)
# }

# module "web_server" {
#     source = "./aws/modules/web_server"

#     vpc_id          = module.vpc.vpc_id
#     vpc_cidr        = module.vpc.vpc_cidr
#     private_subnets = module.vpc.private_subnets_ids
#     public_subnets  = module.vpc.public_subnets_ids
#     user_data       = data.template_file.web_server_ud.rendered
#     key_name        = local.ssh_key_name
#     ami             = local.aws_ec2_ami
#     my_ips          = var.my_ips
#     instance_type   = local.aws_ec2_type
# }

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
  # api_origin_id         = local.api_origin_id
  # api_domain_name       = module.web_server.domain_name
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

