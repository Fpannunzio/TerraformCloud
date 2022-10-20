# Input variable definitions
variable "OAI" {
  description = "OAI"
  type        = map(any)
}

variable "s3_origin_id" {
  type        = string
}

variable "api_origin_id" {
  type        = string
}

variable "api_domain_name" {
  type        = string
}

variable "bucket_domain_name" {
  type        = string
}

variable "aliases" {
  type        = set(string)
}

variable "certificate_arn" {
  type        = string
  # default     = null
}