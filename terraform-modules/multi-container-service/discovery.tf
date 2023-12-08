resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = local.discovery_domain
  description = "Discovery for ${var.project_name} in ${var.environment}"
  vpc         = var.shared_configuration.vpc_id
}
