variable "base_domain" {
  description = "The base domain of the application"
  type        = string
}

variable "aws_region" {
  description = "The aws regions"
  type        = string
}

variable "aws_account_id" {
  description = "The aws account id"
  type        = string
}

variable "cloudfront_dist" {
  description = "The cloudfront distribution"
}

variable "lambda" {
  description = "The aws lambda to trigger"
}
# variable "api_key_id" {
#   description = "The API gateway key id"
#   type        = string
# }