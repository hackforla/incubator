// The *.civictechindex.org certificate, which serves api and api-stage. Note it does NOT
// cover the apex -- a wildcard matches one label only. The apex is an S3 website endpoint
// and serves over plain HTTP, so nothing needs it to. Adopted in hackforla/incubator#185;
// the validation record it manages was declared standalone in dns.tf by
// hackforla/incubator#183 and moved here.
//
// The Name tag is on the live certificate. Stated here because the provider would
// otherwise plan to strip it.
module "certificate" {
  source = "../../modules/acm-certificate"

  domain_name = "*.civictechindex.org"
  zone_id     = aws_route53_zone.this.zone_id

  tags = {
    Name = "wildcard.civictechindex.org"
  }
}
