output "domain_name" {
  description = "The api gateway domain name"
  value       = join(".", [aws_api_gateway_rest_api.this.id, "execute-api", var.aws_region, "amazonaws.com"])
}

output "id" {
  description = "The api gateway domain name"
  value       = aws_api_gateway_rest_api.this.id
}

output "resource_id" {
  description = "The api gateway resource_id"
  value       = aws_api_gateway_rest_api.this.root_resource_id
}


