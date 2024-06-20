data "aws_route53_zone" "selected" {
  count = var.aws_managed_dns ? 1 : 0
  name         = regexall("[^.]*?.[^.]*?$", var.host_names[0])[0]
  private_zone = false
}

# Resource for root domain A record with alias
resource "aws_route53_record" "root" {
  count = var.aws_managed_dns && length(regexall("[^.]*?.[^.]*?$", var.host_names[0])) > 0 ? 1 : 0

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = regexall("[^.]*?.[^.]*?$", var.host_names[0])[0]
  type    = "A"

  alias {
    name                   = var.alb_external_dns
    zone_id                = data.aws_route53_zone.selected[0].zone_id
    evaluate_target_health = false
  }
}

# Resource for subdomain CNAME records
resource "aws_route53_record" "subdomain" {
  for_each = var.aws_managed_dns ? { for v in var.host_names : v => v if v != regexall("[^.]*?.[^.]*?$", var.host_names[0])[0] } : {}

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = each.value
  type    = "CNAME"
  ttl     = "300"
  records = [var.alb_external_dns]
}

variable "alb_external_dns" {
  description = "Application Load Balancer External A Record for R53 Record"
  type        = string
}

variable "aws_managed_dns" {
  type        = bool
  description = "Flag to either create record if domain is managed in AWS or output ALB DNS for user to manually create"
}