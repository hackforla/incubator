output "internal_dns_name" {
  value = "${aws_service_discovery_service.sd_service.name}.${var.private_dns_name}"
}