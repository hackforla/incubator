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

// The module used to key its validation records by record name and now keys them by
// domain, so a new certificate can plan. This carries the existing record across
// without recreating it. See hackforla/incubator#285.
moved {
  from = module.certificate_stage.aws_route53_record.validation["_1ca49dd660678abe9478619c13875864.stage.civictechjobs.org."]
  to   = module.certificate_stage.aws_route53_record.validation["stage.civictechjobs.org"]
}
