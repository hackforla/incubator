output "arn" {
  value       = aws_acm_certificate_validation.this.certificate_arn
  description = "the certificate arn, available only once ACM reports it ISSUED"
}

output "domain_name" {
  value       = aws_acm_certificate.this.domain_name
  description = "the certificate's primary domain, i.e. `*.vrms.io`"
}
