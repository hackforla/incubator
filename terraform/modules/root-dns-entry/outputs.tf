output "full_dns_name" {
    value = data.aws_route53_zone.this.name
}