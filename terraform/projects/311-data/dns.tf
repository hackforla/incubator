// 311-data.org. DNS only -- the site is served from GitHub Pages out of
// hackforla/311-landingpage, not from anything in this account. Note the serving
// repo is 311-landingpage, NOT hackforla/311-data, which has Pages enabled with no
// custom domain. See hackforla/incubator#183.

resource "aws_route53_zone" "this" {
  name = "311-data.org"

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
  name    = "311-data.org"
  type    = "A"
  ttl     = 300
  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

// This pointed at the apex until hackforla/incubator#183, which broke HTTPS: the
// request arrives with SNI www.311-data.org and GitHub's certificate covers the
// apex only, so TLS failed outright while plain HTTP kept working. Pointing at
// hackforla.github.io is what makes GitHub issue a certificate for the www name --
// it is the same shape as www.ballotnav.org and www.civictechjobs.org, both of
// which redirect to their apex correctly over HTTPS. Do not point this back at
// the apex.
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "www.311-data.org"
  type    = "CNAME"
  ttl     = 300
  records = ["hackforla.github.io"]
}
