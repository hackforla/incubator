
resource "aws_route53_zone" "main" {
  name = local.root_host_name
}

resource "aws_route53_record" "root_a_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.root_host_name
  type    = "A"
  ttl     = 300
  records = ["18.223.160.58"]
}
