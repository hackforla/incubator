data "aws_route53_zone" "selected" {
  count = var.aws_managed_dns ? 1 : 0
  name         = regexall("[^.]*?.[^.]*?$", var.host_names[0])[0]
  private_zone = false
}

resource "aws_route53_record" "www" {
  for_each = var.aws_managed_dns ? toset(var.host_names) : []

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
  description = "flag to either create record if domain is managed in AWS or output ALB DNS for user to manually create"
}
