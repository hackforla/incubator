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

// The foodoasis.net certificate. Nothing routes to it until the staging and production
// services exist (hackforla/incubator#281, #282); the wildcard covers their hostnames.
//
// It is created while the domain's nameservers still point at the Food Oasis account's
// zone Z05347102APWJD0S0P604, so ACM cannot see the validation record written into
// aws_route53_zone.this. The same record was copied into that zone by hand during the
// first apply, and stays there because ACM renews through it. See hackforla/incubator#283.
module "certificate_foodoasis_net" {
  source = "../../modules/acm-certificate"

  domain_name               = "foodoasis.net"
  subject_alternative_names = ["*.foodoasis.net"]
  zone_id                   = aws_route53_zone.this.zone_id
}
