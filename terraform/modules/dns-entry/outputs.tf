output "full_dns_name" {
    value = "${var.subdomain}.${data.aws_route53_zone.this.name}"
}