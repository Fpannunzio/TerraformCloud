# Input variable definitions

variable "vpc_id" {
  description = "VPC."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC cidr"
  type        = string
}

variable "private_subnets" {
  description = "Private subnets for the web servers"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets for load balancer"
  type        = list(string)
}

variable "user_data" {
  description = "User data for web server inizialization"
  type        = string
  # sensitive   = true
}

variable "ami" {
  description = "AMI"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "my_ips" {
  description = "IPs whitelisted for SSH access"
  type        = list(string)
}
