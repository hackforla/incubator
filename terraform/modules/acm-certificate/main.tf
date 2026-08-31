/**
 * # acm-certificate
 *
 * Requests an ACM certificate, proves ownership of its domains through DNS in a Route 53
 * hosted zone this account holds, and attaches it to the incubator production load
 * balancer's HTTPS listener as an SNI certificate.
 *
 * All three halves belong together. A certificate whose validation records live somewhere
 * else silently stops renewing when those records are edited, and a certificate that is
 * not attached to anything becomes ineligible for renewal and expires -- which is what
 * happened to the `civictechjobs.org` certificate, deleted in hackforla/incubator#185.
 *
 * Two things to watch out for:
 *
 * 1. `validation_record_ttl` defaults to 300, but the certificates adopted in #185 were
 * created by hand with a mix of 60 and 300. Pass the live value when adopting an existing
 * certificate, otherwise the first plan rewrites a working validation record for no reason.
 *
 * 2. The validation records are keyed by record name rather than by domain name. A
 * wildcard certificate emits an identical validation record for `*.example.org` and
 * `example.org`, so keying by domain name produces two resources writing one name and the
 * plan fails.
 *
 * Removing a certificate: the destroy order is correct without help. Terraform destroys in
 * reverse dependency order, so it detaches from the listener first and deletes the
 * certificate last, which is what ACM requires -- and the provider retries DeleteCertificate
 * on ResourceInUseException for 20 minutes, which covers the lag between a detach and ACM
 * noticing it. The hazard is a partial failure: the validation records are destroyed before
 * the certificate, so if the delete fails anyway -- most plausibly because the certificate is
 * also attached to something outside Terraform, another listener or a CloudFront
 * distribution -- you are left with a live certificate whose validation records are gone. It
 * keeps serving and silently stops renewing. If a destroy fails here, check
 * `aws acm describe-certificate --query Certificate.InUseBy` and fix the real attachment
 * rather than re-running.
 *
 * Known limitation: for a certificate that already exists and is adopted with an `import`
 * block, the validation record names are read during the plan and everything applies in one
 * pass. For a brand new certificate they are hashes ACM has not issued yet, so `for_each`
 * cannot be resolved and the first apply may need a second run. Nothing in #185 creates a
 * certificate, so this has not been worked around.
 */

// terraform-docs-ignore
data "aws_lb" "this" {
  name = "incubator-prod-lb"
}

// terraform-docs-ignore
data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.this.arn
  port              = 443
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  tags = var.tags

  // Changing domain_name or subject_alternative_names replaces the certificate. Creating
  // the replacement first means it can be validated and attached before the old one is
  // detached, so there is no window where the listener serves nothing for these names.
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  // Grouping mode: several domains on one certificate can share a validation record, and
  // a plain map comprehension errors on the duplicate key. Each group's entries are
  // identical, so taking the first below is safe.
  validation_records = {
    for dvo in aws_acm_certificate.this.domain_validation_options :
    dvo.resource_record_name => {
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }...
  }
}

// Deleting one of these does not break TLS today -- it stops the certificate renewing, and
// the failure surfaces up to a year later as an expiry.
resource "aws_route53_record" "validation" {
  for_each = { for name, records in local.validation_records : name => records[0] }

  zone_id = var.zone_id
  name    = each.key
  type    = each.value.type
  ttl     = var.validation_record_ttl
  records = [each.value.record]
}

// Creates nothing in AWS. It blocks until ACM reports the certificate ISSUED, which is what
// lets the listener attachment below depend on a usable certificate.
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

// Reading the arn from the validation resource rather than from the certificate is what
// orders these: ELB rejects a certificate that is still PENDING_VALIDATION.
//
// This adds the certificate to the listener's SNI list. The listener's *default*
// certificate is an attribute of the listener itself, so it is not set here -- see
// projects/vrms/certificate.tf.
resource "aws_lb_listener_certificate" "this" {
  count = var.attach_to_load_balancer ? 1 : 0

  listener_arn    = data.aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate_validation.this.certificate_arn
}
