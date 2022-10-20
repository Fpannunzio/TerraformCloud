
data "aws_cloudfront_cache_policy" "disabled" {
    name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "optimized" {
    name = "Managed-CachingOptimized"
}

# data "aws_cloudfront_origin_access_identity" "s3" {
#   id = var.OAI_id
# }

resource "aws_cloudfront_distribution" "redes" {
  # Si se usa www hay problemas de permisos, la policy dice que solo cloudfront lee pega a site
  origin {
    domain_name = var.bucket_domain_name
    origin_id   = var.s3_origin_id

    s3_origin_config {
      # origin_access_identity = data.aws_cloudfront_origin_access_identity.s3.cloudfront_access_identity_path
      origin_access_identity = var.OAI.cloudfront_access_identity_path
    }
  }
  
  origin {
    domain_name = var.api_domain_name
    origin_id   = var.api_origin_id

    custom_origin_config {
        origin_protocol_policy = "http-only"
        origin_ssl_protocols = ["TLSv1.2"]
        https_port = 443
        http_port = 80
    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "cdn"
  default_root_object = "index.html"
  aliases             = var.aliases

  # Configure logging here if required 	
  # logging_config {
  #  include_cookies = false
  #  bucket          = aws_s3_bucket.cdnlogs.id
  # #  prefix          = "myprefix"
  # }
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_origin_id
    cache_policy_id  = data.aws_cloudfront_cache_policy.optimized.id

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id  = data.aws_cloudfront_cache_policy.disabled.id
    target_origin_id = var.api_origin_id

    min_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "cdn"
  }

  viewer_certificate {
    cloudfront_default_certificate = length(var.aliases) == 0

    acm_certificate_arn       = var.certificate_arn
    minimum_protocol_version  = length(var.aliases) > 0 ? "TLSv1.2_2021" : null
    ssl_support_method        = length(var.aliases) > 0 ? "sni-only" : null
  }
}