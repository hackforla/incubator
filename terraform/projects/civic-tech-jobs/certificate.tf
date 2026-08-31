// The stage.civictechjobs.org certificate, serving the stage environment through listener
// rule 200. Adopted in hackforla/incubator#185; the validation record it manages was
// declared standalone in dns.tf by hackforla/incubator#183 and moved here.
//
// There is no certificate for the apex or www. Both are served by GitHub Pages with
// GitHub's own certificate. An ACM certificate for the apex did exist, attached to nothing
// and therefore ineligible for renewal, and was deleted in #185 rather than adopted.
module "certificate_stage" {
  source = "../../modules/acm-certificate"

  domain_name = "stage.civictechjobs.org"
  zone_id     = aws_route53_zone.this.zone_id
}
