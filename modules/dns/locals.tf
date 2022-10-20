locals {
  app_domain       = "${var.app_subdomain}.${var.base_domain}"
  pri_app_domain   = "${var.primary_subdomain}.${var.base_domain}"
  sec_app_domain   = "${var.secondary_subdomain}.${var.base_domain}"
}