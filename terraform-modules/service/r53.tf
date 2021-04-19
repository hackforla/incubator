// data "aws_route53_zone" "selected" {
//   count        = var.domain_name == "" ? 0 : 1
//   name         = var.domain_name
//   private_zone = false
// }

// resource "aws_route53_record" "www" {
//   for_each = toset(var.host_names)

//   zone_id = data.aws_route53_zone.selected[0].zone_id
//   name    = each.value
//   type    = "CNAME"
//   ttl     = "300"
//   records = [var.alb_external_dns]
// }

// variable "domain_name" {
//   description = "The domain name where the application will be deployed, must already live in AWS"
//   type        = string
// }

// variable "host_names" {
//   description = "The URL where the application will be hosted, must be a subdomain of the domain_name"
//   type        = list(string)
// }

// variable "alb_external_dns" {
//   description = "Application Load Balancer External A Record for R53 Record"
//   type        = string
// }
