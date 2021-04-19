data "aws_route53_zone" "selected" {
  count        = var.aws_managed_dns ? 1 : 0
  // name         = join(".", split(".", var.host_names[0])[-2])
  // name = regexall("[^.]*?.[^.]*?$", var.host_names[0])
  // name = format("%s.", "ballo.nav")
  // name = "ballotnav.org"
  name = regexall("[^.]*?.[^.]*?$", var.host_names[0])[0]
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

output "regex_test" {
  value = regexall("[^.]*?.[^.]*?$", var.host_names[0])
}

// variable "host_names" {
//   description = "The URL where the application will be hosted, must be a subdomain of the domain_name"
//   type        = list(string)
// }

variable "alb_external_dns" {
  description = "Application Load Balancer External A Record for R53 Record"
  type        = string
}

variable "aws_managed_dns" {
  type = bool
  description = "flag to either create record if domain is managed in AWS or output ALB DNS for user to manually create"
}