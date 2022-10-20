# Output variable definitions

output "domain_name" {
  description = "Domain Name of the public load balanceer"
  value       = aws_lb.web.dns_name
}
