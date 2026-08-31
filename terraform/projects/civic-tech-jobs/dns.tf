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

// DNS validation for the ACM certificate civictechjobs.org
// (arn:...:certificate/b6bea889-5221-4425-b09c-716199866af6). That certificate is
// ISSUED but attached to nothing -- the apex is served by GitHub Pages, so an ALB
// certificate for it is unused. The record still has to stay or renewal fails.
// Both this and the certificate are for the ACM task to resolve, not this one.
resource "aws_route53_record" "cert_validation_apex" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "_a57d306f01d9b44fbca0d00a608ea608.civictechjobs.org"
  type    = "CNAME"
  ttl     = 300
  records = ["_bfd3a50aa6f2f2dec50d28873885838d.tctzzymbbs.acm-validations.aws."]
}

// DNS validation for the ACM certificate stage.civictechjobs.org
// (arn:...:certificate/af0b30d5-0d64-4065-905b-eaced30fe8ba), which is attached to
// incubator-prod-lb and serves the stage environment. The value has no trailing dot
// where the others in this account do; Route 53 treats both as absolute, and it is
// reproduced verbatim so it does not show as a diff. Moves to the certificate
// resource when ACM comes into Terraform.
resource "aws_route53_record" "cert_validation_stage" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "_1ca49dd660678abe9478619c13875864.stage.civictechjobs.org"
  type    = "CNAME"
  ttl     = 300
  records = ["_aaf9335595c8bd7c846a550221d3b3e4.tctzzymbbs.acm-validations.aws"]
}
