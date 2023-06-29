data "aws_route53_zone" "selected" {
  count        = var.domain_name == "" ? 0 : 1
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "www" {
  for_each = toset(var.host_names)

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = each.value
  type    = "CNAME"
  ttl     = "300"
  records = [var.alb_external_dns]
}
