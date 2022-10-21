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

variable "base_domain" {
  description = "Application base domain"
  type        = string
}

variable "aws_account_id" {
  description = "The aws account id"
  type        = string
}

variable "aws_region" {
  description = "The aws region"
  type        = string
}

variable "gateway_id" {
  description = "The api gateway id"
  type        = string
}

variable "gateway_resource_id" {
  description = "The api gateway resource id"
  type        = string
}

variable "path_part" {
  description = "The path to call lambda"
  type        = string
}

variable "http_method" {
  description = "The http method to call lambda"
  type        = string
}

variable "status_code" {
  description = "The http method to call lambda"
  type        = string
}