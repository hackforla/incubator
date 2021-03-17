resource "aws_service_discovery_service" "sd_service" {
  name = local.envname
  namespace_id = var.private_dns_id

  dns_config {
    namespace_id = var.private_dns_id

    dns_records {
      ttl  = 60
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

}