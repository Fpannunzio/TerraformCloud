data "aws_route53_zone" "main" {
  name = var.base_domain
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${local.app_domain}"
  type    = "CNAME"

  alias {
    name    = aws_route53_record.demo_primary.name
    zone_id =  data.aws_route53_zone.main.id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "primary" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${local.pri_app_domain}"
  type    = "A"

  alias {
    name    = var.pri_deploy_cloudfront.domain_name
    zone_id = var.pri_deploy_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "secondary" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${local.sec_app_domain}"
  type    = "NS"


  allow_overwrite = true
  ttl             = 300

  records = var.sec_deploy_name_servers
}

resource "aws_route53_health_check" "web" {
  port              = 443
  type              = "HTTPS"
  fqdn              = "${local.pri_app_domain}"
  resource_path     = var.app_primary_health_check_path
  failure_threshold = "3"
  request_interval  = "30"
}

resource "aws_route53_record" "demo_primary" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${local.app_domain}"
  type    = "CNAME"
  ttl     = 300

  records = ["${local.pri_app_domain}"]

    failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.web.id

  set_identifier  = "record-app-primary"
}

resource "aws_route53_record" "demo_secondary" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${local.app_domain}"
  type    = "CNAME"
  ttl     = 300

  records = ["${local.sec_app_domain}"]

    failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier  = "record-app-secondary"
}

