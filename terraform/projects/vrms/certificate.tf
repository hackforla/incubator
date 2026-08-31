// The *.vrms.io certificate, which also covers the apex. Adopted in
// hackforla/incubator#185; the validation record it manages was declared standalone in
// dns.tf by hackforla/incubator#183 and moved here.
//
// This is also incubator-prod-lb's DEFAULT certificate -- the one served to a client whose
// SNI matches nothing else, which is why every name under vrms.io used to complete a TLS
// handshake and fall through to the listener's redirect. The default is an attribute of
// the listener, not of the certificate, so the module cannot set it and this certificate
// keeps a separate SNI attachment. The default assignment lands when the load balancer
// itself comes into Terraform.
module "certificate" {
  source = "../../modules/acm-certificate"

  domain_name               = "*.vrms.io"
  subject_alternative_names = ["vrms.io"]
  zone_id                   = aws_route53_zone.this.zone_id
}
