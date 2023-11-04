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
  zone_id = aws_route53_zone.this.zone_id
  name    = aws_route53_zone.this.name
  type    = "A"

  alias {
    name                   = data.aws_lb.lb.dns_name
    zone_id                = data.aws_lb.lb.zone_id
    evaluate_target_health = true
  }
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
