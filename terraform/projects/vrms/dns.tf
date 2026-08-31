// vrms.io. Unlike the GitHub Pages zones, everything here points at
// incubator-prod-lb. Two records in this zone are declared elsewhere: dev.vrms.io by
// the dns-entry module in environment-dev.tf, and peopledepot-dev.vrms.io by the
// people-depot project, which reaches this zone through the zone_id output below.
// See hackforla/incubator#183.
//
// A wildcard CNAME *.vrms.io pointed at the load balancer until August 2026. It was
// created by hand -- no Terraform or Terragrunt in this repo's history ever declared
// it -- and paired with the *.vrms.io certificate, which is still the 443 listener's
// DEFAULT certificate. Together they meant every conceivable name under vrms.io
// resolved, completed a TLS handshake and fell through to the listener default
// action, which redirects to www.hackforla.org. It was deleted deliberately so that
// names without a record NXDOMAIN instead. Do not recreate it: every host named in an
// ALB listener rule has its own record below or in the files named above, so nothing
// depends on it.

resource "aws_route53_zone" "this" {
  name = "vrms.io"

  // The live zone has an empty comment. The provider defaults this attribute to
  // "Managed by Terraform", so omitting it would plan a change against a live zone.
  comment = ""

  // Destroying a hosted zone discards its delegation NS set. A recreated zone gets
  // different nameservers, so the outage is not recoverable from Terraform.
  lifecycle {
    prevent_destroy = true
  }
}

// peopledepot-dev.vrms.io lives in this zone but belongs to the people-depot
// project. main.tf passes this into that module rather than repeating the zone id.
output "zone_id" {
  value       = aws_route53_zone.this.zone_id
  description = "the vrms.io hosted zone id, for records owned by other projects"
}

// The apex is an alias to the load balancer, not a CNAME -- a zone apex cannot hold
// a CNAME. Z1H1FL5HABSF5 is the canonical hosted zone id of the us-west-2 ALB
// service, not of incubator-prod-lb itself. Both prod services set
// hostname = "vrms.io" with additional_host_urls = ["www.vrms.io"], listener rules
// 402 and 403.
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "vrms.io"
  type    = "A"

  alias {
    name                   = "incubator-prod-lb-569274394.us-west-2.elb.amazonaws.com."
    zone_id                = "Z1H1FL5HABSF5"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "www.vrms.io"
  type    = "CNAME"
  ttl     = 300
  records = ["incubator-prod-lb-569274394.us-west-2.elb.amazonaws.com"]
}

// The DNS validation record for the *.vrms.io certificate used to be declared here. It
// moved to the acm-certificate module in certificate.tf, which owns the certificate, its
// validation records and its load balancer attachment together.
// See hackforla/incubator#185.
