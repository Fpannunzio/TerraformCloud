# variable ssh_key_path {
#   description = "SSH public key location needed to access aws instances"
#   type        = string
# }

# variable my_ips {
#   description = "Public IPs of the user. AWS EC2 access is restricted to those IPs."
#   type        = list(string)
# }

variable aws_region {
  description = "AWS Region in which to deploy the application"
  type = string
  }

variable base_domain {
  description = "Base domain for the whole application. A subdomain of an already established domain."
  type = string
  }

# variable gcp_project {
#   description = "Name of the GCP project to use"
#   type = string
# }
# variable gcp_region {
#   description = "GCP Region in which to deploy the application"
#   type = string
# }
# variable gcp_user {
#   description = "GCP user for terraform to use. Probably the same used to authenticate on GCP."
#   type = string
#   }