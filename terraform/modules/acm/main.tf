# Find a certificate that is issued
data "aws_acm_certificate" "issued" {
  for_each = toset(var.domain_names)
  domain   = "*.${each.value}"
  statuses = ["ISSUED"]
}
