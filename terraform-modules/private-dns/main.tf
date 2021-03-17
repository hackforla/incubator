resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = local.envname
  description = "Private namesprace for ${var.resource_name} resources"
  vpc         = var.vpc_id
  tags = var.tags
}

output "private_dns_id" {
  value = aws_service_discovery_private_dns_namespace.this.id
}

output "private_dns_name" {
  value = aws_service_discovery_private_dns_namespace.this.name
}