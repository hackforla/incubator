output "acm_certificate_arn" {
  value = var.wildcard_cert_arn != "" ? var.wildcard_cert_arn : element(concat(aws_acm_certificate.cert.*.arn, [""]), 0)
}

// : element(concat(data.aws_acm_certificate.issued.*.arn, [""]), 0)