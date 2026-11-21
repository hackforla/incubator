// foodoasis.la. This zone started as a copy of the live Cloudflare zone
// (hackforla/incubator#285). Since hackforla/devops#238 its web names, www and the seven
// region names, point at the load balancer from environment-prod.tf, and the bare domain
// below is served by the production service directly. Its web hostnames match
// foodoasis.net's. What each record is: hackforla/devops#236.
//
// search, staging, vote and mail were deliberately not copied. None of them serves
// anything. See hackforla/incubator#285.

resource "aws_route53_zone" "foodoasis_la" {
  name = "foodoasis.la"

  // The provider defaults this attribute to "Managed by Terraform".
  comment = "foodoasis.la - Food Oasis. Copied from Cloudflare, hackforla/incubator#285"

  // Destroying a hosted zone discards its delegation NS set. A recreated zone gets
  // different nameservers, so the outage is not recoverable from Terraform.
  lifecycle {
    prevent_destroy = true
  }
}

// Also used by foodoasis.net's bare domain in dns.tf.
data "aws_lb" "incubator" {
  name = "incubator-prod-lb"
}

// The load balancer is IPv4 only, so there is no AAAA alias. Cloudflare answered AAAA for
// this name only because it proxied it. The production service's listener rule serves it.
resource "aws_route53_record" "foodoasis_la_apex" {
  zone_id = aws_route53_zone.foodoasis_la.zone_id
  name    = "foodoasis.la"
  type    = "A"

  alias {
    name                   = data.aws_lb.incubator.dns_name
    zone_id                = data.aws_lb.incubator.zone_id
    evaluate_target_health = false
  }
}

// @foodoasis.la email is hosted by Zoho. These three records are copied unchanged.
resource "aws_route53_record" "foodoasis_la_mx" {
  zone_id = aws_route53_zone.foodoasis_la.zone_id
  name    = "foodoasis.la"
  type    = "MX"
  ttl     = 300
  records = ["10 mx.zoho.com", "20 mx2.zoho.com"]
}

resource "aws_route53_record" "foodoasis_la_txt" {
  zone_id = aws_route53_zone.foodoasis_la.zone_id
  name    = "foodoasis.la"
  type    = "TXT"
  ttl     = 300
  records = [
    "v=spf1 include:zoho.com ~all",
    "google-site-verification=tyXNoLKw2VjgRglbyodhn048nLisVaCQRTIZDHWmcbw",
  ]
}

resource "aws_route53_record" "foodoasis_la_zoho_dkim" {
  zone_id = aws_route53_zone.foodoasis_la.zone_id
  name    = "zoho._domainkey.foodoasis.la"
  type    = "TXT"
  ttl     = 300
  records = ["v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCdaiH0QCqMMD3Pbwp098rnWi7ydT8hcZUIwhs4+9gI6us5h54sqtTWFbSJUthQURzTcyau14qRFr1a+nj42t6foA4eSBNsSLLtIDkmlMo1LQhBjuS5hz1Ss+GJz0Gu+2wIZKWETP29AhR+6gONxraMoTcV/laoBCdYrIy1m6T3fQIDAQAB"]
}

