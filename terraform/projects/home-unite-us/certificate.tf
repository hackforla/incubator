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
