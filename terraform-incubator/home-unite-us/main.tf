resource "aws_route53_zone" "main" {
  name = "homeunite.us"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "homeunite.us"
  type    = "A"
  ttl     = 300
  records = ["18.223.160.58"]
}