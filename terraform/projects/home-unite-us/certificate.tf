// The homeunite.us certificate, covering the apex and *.homeunite.us -- so www, qa and qa1
// are all served by this one. Adopted in hackforla/incubator#185; the validation record it
// manages was declared standalone in dns.tf by hackforla/incubator#183 and moved here.
//
// TTL 60 rather than the module default of 300 is the live value, reproduced so adopting
// the record does not rewrite it.
module "certificate" {
  source = "../../modules/acm-certificate"

  domain_name               = "homeunite.us"
  subject_alternative_names = ["*.homeunite.us"]
  zone_id                   = aws_route53_zone.this.zone_id
  validation_record_ttl     = 60
}

// The module used to key its validation records by record name and now keys them by
// domain, so a new certificate can plan. This carries the existing record across
// without recreating it. See hackforla/incubator#285.
moved {
  from = module.certificate.aws_route53_record.validation["_5bb55cc568d53bab04232d9f9e534189.homeunite.us."]
  to   = module.certificate.aws_route53_record.validation["homeunite.us"]
}
