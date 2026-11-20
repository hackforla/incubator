// The foodoasis.la certificate. It serves the bare domain's redirect now, and the app
// once hackforla/devops#238 moves www here; the wildcard covers www.
//
// It was created while the domain's nameservers still pointed at Cloudflare, so ACM could
// not see the validation record written into the Route 53 zone. The same record was added
// in Cloudflare by hand during the first apply. See hackforla/incubator#285.
module "certificate_foodoasis_la" {
  source = "../../modules/acm-certificate"

  domain_name               = "foodoasis.la"
  subject_alternative_names = ["*.foodoasis.la"]
  zone_id                   = aws_route53_zone.foodoasis_la.zone_id
}
