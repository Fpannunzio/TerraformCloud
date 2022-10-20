variable aws_region {
  description = "AWS Region in which to deploy the application"
  type = string
  }

variable base_domain {
  description = "Base domain for the whole application. A subdomain of an already established domain."
  type = string
}