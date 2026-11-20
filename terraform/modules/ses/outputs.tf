output "arn" {
  value       = aws_sesv2_email_identity.this.arn
  description = "the identity arn, for scoping `ses:SendEmail` permissions"
}

output "dkim_records" {
  value = local.is_domain ? [
    for token in aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens : {
      name  = "${token}._domainkey.${var.identity}"
      type  = "CNAME"
      value = "${token}.dkim.amazonses.com"
    }
  ] : []
  description = "the domain's three DKIM records as a list of `name`, `type` and `value`, whether or not the module wrote them. Empty for an email address"
}

output "mail_from_records" {
  value = [
    for record in values(local.mail_from_records) : {
      name  = local.mail_from_domain
      type  = record.type
      value = record.value
    }
  ]
  description = "the custom MAIL FROM domain's MX and SPF records as a list of `name`, `type` and `value`, whether or not the module wrote them. Empty when `mail_from_subdomain` is unset"
}
