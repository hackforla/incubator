resource "aws_acm_certificate" "cert" {
  count = var.wildcard_cert_arn == "" ? 1 : 0
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

# Find a certificate that is issued
data "aws_acm_certificate" "issued" {
  count = var.wildcard_cert_arn == "" ? 0 : 1
  domain   = "*.${var.domain_name}"
  statuses = ["ISSUED"]
}
