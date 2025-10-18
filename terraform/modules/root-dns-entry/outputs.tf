output "full_dns_name" {
    value = data.aws_route53_zone.this.name
    description = "full dns name, i.e. \"qa.vrms.io\""
}