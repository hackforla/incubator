output "acm_certificate_arns" {
  value = [
    for cert in data.aws_acm_certificate.issued : cert.arn
  ]

  // value = zipmap(values(aws_secretsmanager_secret.application-secret)[*]["arn"]))
}
