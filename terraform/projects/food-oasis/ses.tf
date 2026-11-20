// The SES sending identity for foodoasis.net in the incubator account. The app sends every
// email as EMAIL_USER, donotreply@foodoasis.net, so the domain identity covers all of it and
// no address identity is needed. The containers send through their task role, using
// modules/ses-container-permissions with this identity's arn (hackforla/incubator#281, #282).
//
// The module writes the three DKIM records into aws_route53_zone.this. Until the nameserver
// switch (hackforla/incubator#294) the Food Oasis account's zone Z05347102APWJD0S0P604 is
// the live one, so the same three records were copied into it by hand after the first apply.
// SES verifies against public DNS only.
//
// The Food Oasis account's own foodoasis.net identity, and its six DKIM records in dns.tf,
// stay until hackforla/devops#239: Heroku sends through it until production cuts over.
//
// Bounces and complaints are handled by the account-level suppression list, on for both
// (hackforla/incubator#279). No notification topic is set, so SES's feedback emails go to
// donotreply@foodoasis.net, which has no mailbox.
//
// bounce.foodoasis.net is the custom MAIL FROM domain, so SPF aligns with the From domain as
// well as DKIM. Its MX and SPF records were copied into the Food Oasis zone too. The Food
// Oasis account's identity was deliberately left on SES's default MAIL FROM.
module "ses_foodoasis_net" {
  source = "../../modules/ses"

  identity            = "foodoasis.net"
  zone_id             = aws_route53_zone.this.zone_id
  mail_from_subdomain = "bounce"

  tags = {
    project = local.project_name_food_oasis
  }
}
