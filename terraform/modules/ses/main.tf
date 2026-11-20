/**
 * # ses
 *
 * Creates one SES sending identity, either a domain or a single email address. A domain
 * gets Easy DKIM with 2048-bit keys, so mail sent from any address at that domain is signed.
 * An email address can only send as itself and has no DKIM records. The identity is created
 * in the provider's region, which for the incubator is us-west-2. Senders must call SES in
 * that same region.
 *
 * Zone-less mode: `zone_id` is optional. When it is set, the module writes the domain's
 * three DKIM CNAME records into that Route 53 zone. When it is not, the module writes no
 * DNS at all and the records only appear in the `dkim_records` output, for adding by hand
 * wherever the domain's DNS lives. Use this for a domain whose zone is not in this account
 * yet. SES keeps checking for the records and verifies the domain once they resolve.
 *
 * Why the DKIM records use `count = 3` rather than `for_each` over the tokens: Easy DKIM
 * always issues exactly three tokens, but their values are unknown until the identity
 * exists, and `for_each` keys must be known at plan time. A fixed count plans for a new
 * identity in a single pass. `acm-certificate` has the same problem with its validation
 * records and documents it as a known limitation there.
 *
 * Known limitation: whether the records are written depends on whether `zone_id` is null,
 * so `zone_id` must be known at plan time. A zone that already exists is fine. A zone
 * created in the same apply is not: its id is unknown during the plan, and the plan fails
 * with "Invalid count argument". Apply the zone first, or leave `zone_id` unset and add the
 * records later.
 *
 * Custom MAIL FROM: set `mail_from_subdomain` to send with an envelope sender (Return-Path)
 * of `<subdomain>.<domain>` instead of SES's own `amazonses.com`. Without it, SPF passes for
 * amazonses.com, which does not match the From domain, and the SES console warns "MAIL FROM
 * record is not aligned". DMARC still passes through DKIM, which is aligned, so the subdomain
 * adds a second aligned path rather than fixing a delivery failure. It needs an MX record
 * pointing bounces back at SES's feedback endpoint and an SPF record; with `zone_id` set the
 * module writes both, otherwise they appear only in the `mail_from_records` output. If the MX
 * record is missing, SES falls back to its own domain rather than rejecting mail.
 *
 * New accounts start in the SES sandbox. Until AWS approves production access for the
 * account and region, SES only sends to verified addresses and domains, at most 200
 * messages a day. Requesting production access is a manual step in the SES console and is
 * not done here.
 */

// terraform-docs-ignore
data "aws_region" "current" {}

locals {
  is_domain = !strcontains(var.identity, "@")

  mail_from_domain = var.mail_from_subdomain == null ? null : "${var.mail_from_subdomain}.${var.identity}"

  // The two records a custom MAIL FROM domain needs. The MX target is per region, not per
  // account, so the same records serve an identity for this domain in any account.
  mail_from_records = local.mail_from_domain == null ? {} : {
    mx  = { type = "MX", value = "10 feedback-smtp.${data.aws_region.current.region}.amazonses.com" }
    spf = { type = "TXT", value = "v=spf1 include:amazonses.com ~all" }
  }
}

resource "aws_sesv2_email_identity" "this" {
  email_identity = var.identity

  // SES accepts DKIM signing attributes only for a domain identity.
  dynamic "dkim_signing_attributes" {
    for_each = local.is_domain ? [1] : []
    content {
      next_signing_key_length = "RSA_2048_BIT"
    }
  }

  tags = var.tags
}

resource "aws_route53_record" "dkim" {
  count = local.is_domain && var.zone_id != null ? 3 : 0

  zone_id = var.zone_id
  name    = "${aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens[count.index]}._domainkey.${var.identity}"
  type    = "CNAME"
  ttl     = 1800
  records = ["${aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_sesv2_email_identity_mail_from_attributes" "this" {
  count = local.mail_from_domain == null ? 0 : 1

  email_identity   = aws_sesv2_email_identity.this.email_identity
  mail_from_domain = local.mail_from_domain

  // USE_DEFAULT_VALUE sends with amazonses.com while the MX record is missing; REJECT_MESSAGE
  // would stop all mail instead.
  behavior_on_mx_failure = "USE_DEFAULT_VALUE"
}

resource "aws_route53_record" "mail_from" {
  for_each = var.zone_id == null ? {} : local.mail_from_records

  zone_id = var.zone_id
  name    = local.mail_from_domain
  type    = each.value.type
  ttl     = 1800
  // Unquoted: the provider adds the quotes Route 53 needs around a TXT value. Quoting it
  // here as well sends ""v=spf1 ..."", which Route 53 rejects with InvalidCharacterString.
  records = [each.value.value]
}
