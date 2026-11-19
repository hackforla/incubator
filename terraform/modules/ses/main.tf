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
 * New accounts start in the SES sandbox. Until AWS approves production access for the
 * account and region, SES only sends to verified addresses and domains, at most 200
 * messages a day. Requesting production access is a manual step in the SES console and is
 * not done here.
 */

locals {
  is_domain = !strcontains(var.identity, "@")
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
