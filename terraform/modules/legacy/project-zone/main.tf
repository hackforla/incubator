variable "zone_name" {
  type = string
}

variable "shared_configuration" {
  description = "Configuration object from shared resources"
  type = object({
    alb_arn                = string
    alb_https_listener_arn = string
  })
}

variable "github_at_apex" {
  type    = bool
  default = false
}

output "zone_id" {
  value = aws_route53_zone.this.zone_id
}

resource "aws_route53_zone" "this" {
  name = var.zone_name
}

// Create an Apex DNS record that aliases to the LB
data "aws_lb" "lb" {
  arn = var.shared_configuration.alb_arn
}

resource "aws_route53_record" "apex" {
  count   = var.github_at_apex ? 0 : 1
  zone_id = aws_route53_zone.this.zone_id
  name    = aws_route53_zone.this.name
  type    = "A"

  alias {
    name                   = data.aws_lb.lb.dns_name
    zone_id                = data.aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}

// Per https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site#configuring-an-apex-domain
resource "aws_route53_record" "apex-gh" {
  count   = var.github_at_apex ? 1 : 0
  zone_id = aws_route53_zone.this.zone_id
  name    = aws_route53_zone.this.name
  type    = "A"
  ttl     = 3600

  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

resource "aws_route53_record" "apex-gh-ipv6" {
  count   = var.github_at_apex ? 1 : 0
  zone_id = aws_route53_zone.this.zone_id
  name    = aws_route53_zone.this.name
  type    = "AAAA"
  ttl     = 3600

  records = [
    "2606:50c0:8000::153",
    "2606:50c0:8001::153",
    "2606:50c0:8002::153",
    "2606:50c0:8003::153",
  ]
}


resource "aws_acm_certificate" "domain" {
  domain_name               = var.zone_name
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.zone_name}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.domain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "domain" {
  certificate_arn         = aws_acm_certificate.domain.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_lb_listener_certificate" "domain" {
  listener_arn = var.shared_configuration.alb_https_listener_arn

  certificate_arn = aws_acm_certificate_validation.domain.certificate_arn
}
