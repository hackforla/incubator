data "aws_lb" "lb" {
  arn = var.shared_configuration.alb_arn
}

resource "aws_route53_record" "cname" {
  for_each = toset([for n in flatten([for c in var.containers : c.subdomains]) : n])

  zone_id = var.zone_id
  name    = each.value
  type    = "CNAME"
  ttl     = "300"
  records = [data.aws_lb.lb.dns_name]
}
