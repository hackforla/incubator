resource "aws_service_discovery_service" "sd_service" {
  name = "redis"
  description = "redis for caching sessions, etc."
  namespace_id = var.private_dns_id

  dns_config {
    namespace_id = var.private_dns_id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

}