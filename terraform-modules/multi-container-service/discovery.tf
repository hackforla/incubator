resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = local.discovery_domain
  description = "Discovery for ${var.project_name} in ${var.environment}"
  vpc         = var.shared_configuration.vpc_id
}

resource "aws_service_discovery_service" "internal" {
  name = "${local.envname}-internal"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 3
  }
}
