
# resource "aws_route53_zone" "main" {
#   name = local.root_host_name
# }

resource "aws_route53_zone" "original" {
  name = local.root_host_name
}

resource "aws_route53_record" "root_a_record" {
  zone_id = aws_route53_zone.original.zone_id
  name    = local.root_host_name
  type    = "A"

  # alias {
  #   name                   = data.aws_lb.incubator.dns_name
  #   zone_id                = aws_route53_zone.original.zone_id
  #   evaluate_target_health = false
  # }
  ttl     = 300
  records = ["18.223.160.58"]
}

resource "aws_route53_record" "dev_a_record" {
  zone_id = aws_route53_zone.original.zone_id
  name    = "dev.${local.root_host_name}"
  type    = "A"
  ttl     = 300
  records = ["18.223.160.58"]
}


data "aws_lb" "incubator" {
  arn = local.lb_arn
}

# Resource for subdomain CNAME records
resource "aws_route53_record" "subdomain" {
  for_each = { for v in local.host_names : v => v }

  zone_id = aws_route53_zone.original.zone_id
  name    = each.value
  type    = "CNAME"
  ttl     = "300"
  records = [
    data.aws_lb.incubator.dns_name
  ]
}