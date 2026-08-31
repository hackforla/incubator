// civictechjobs.org. The apex and www are served by GitHub Pages out of
// hackforla/CivicTechJobs-comingsoon -- NOT hackforla/CivicTechJobs, which has Pages
// enabled with no custom domain. Only stage.civictechjobs.org reaches AWS, and that
// record is declared by the dns-entry module in environment-stage.tf rather than
// here. See hackforla/incubator#183.

resource "aws_route53_zone" "this" {
  name = "civictechjobs.org"

  // The live zone has an empty comment. The provider defaults this attribute to
  // "Managed by Terraform", so omitting it would plan a change against a live zone.
  comment = ""

  // Destroying a hosted zone discards its delegation NS set. A recreated zone gets
  // different nameservers, so the outage is not recoverable from Terraform.
  lifecycle {
    prevent_destroy = true
  }
}

// GitHub Pages apex addresses, per
// https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site#configuring-an-apex-domain
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "civictechjobs.org"
  type    = "A"
  ttl     = 300
  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "www.civictechjobs.org"
  type    = "CNAME"
  ttl     = 300
  records = ["hackforla.github.io"]
}

// The validation record for the apex certificate used to be declared here. That
// certificate was attached to nothing, which made it ineligible for renewal, and it was
// deleted in hackforla/incubator#185 rather than adopted -- the apex is served by GitHub
// Pages with GitHub's own certificate, so nothing depended on it. This record goes with
// it; it validates a certificate that no longer exists.

// The DNS validation record for the stage.civictechjobs.org certificate used to be
// declared here. It moved to the acm-certificate module in certificate.tf, which owns the
// certificate, its validation records and its load balancer attachment together.
// See hackforla/incubator#185.
