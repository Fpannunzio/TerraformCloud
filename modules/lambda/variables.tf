# variable "aws_authorized_role" {
#   description = "The lambda role"
#   type        = string
# }

variable "tags" {
  description = "The lambda function tags"
  type        = map(any)
}

variable "filename" {
  description = "The lambda executable filename"
  type        = string
}

variable "function_name" {
  description = "The lambda function name"
  type        = string
}

variable "handler" {
  description = "The lambda exectuable handler"
  type        = string
}

variable "runtime" {
  description = "The lambda function runtime"
  type        = string
}

variable "vpc_id" {
  description = "The lambda VPC id"
  type        = string
}

variable "subnet_ids" {
  description = "The lambda VPC subnet ids"
  type        = list(any)
}

