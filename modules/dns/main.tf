data "aws_route53_zone" "main" {
  name = var.base_domain
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.app_domain}"
  type    = "CNAME"

  depends_on = [
    aws_route53_record.main
  ]

  alias {
    name    = aws_route53_record.main.name
    zone_id =  data.aws_route53_zone.main.id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.app_domain}"
  type    = "A"

  alias {
    name    = var.cdn.domain_name
    zone_id = var.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}