# Input variable definitions

variable "authorized_IAM_arn" {
  description = "Authorized terraform users IAM arn"
  type        = list(string)
}

variable "root_IAM_arn" {
  description = "Root IAM arn"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}
