// ballotnav.org. There is no AWS compute behind this project -- the whole site is
// served from GitHub Pages out of hackforla/ballotnav and three sibling repos, so
// this module is DNS only. A zone with nothing in ECS behind it is not abandoned.
// See hackforla/incubator#183.

resource "aws_route53_zone" "this" {
  name = "ballotnav.org"

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
  name    = "ballotnav.org"
  type    = "A"
  ttl     = 300
  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

// Each name here is claimed by its own repo: ballotnav-about, ballotnav-admin,
// ballotnav-demo, and hackforla/ballotnav for www. A CNAME to hackforla.github.io
// with no repo behind it is a subdomain takeover risk -- admin-prod.ballotnav.org
// was deleted in August 2026 for exactly that. Do not add a name here without
// first confirming a repo serves it.
resource "aws_route53_record" "pages" {
  for_each = toset(["about", "admin", "demo", "www"])

  zone_id = aws_route53_zone.this.zone_id
  name    = "${each.key}.ballotnav.org"
  type    = "CNAME"
  ttl     = 300
  records = ["hackforla.github.io"]
}
