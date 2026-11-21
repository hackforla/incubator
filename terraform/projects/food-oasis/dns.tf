// foodoasis.net. This zone starts as a copy of the live zone Z05347102APWJD0S0P604 in the
// Food Oasis account (470363915259), so moving the domain's nameservers here changes
// nothing anyone can see. The web names point at the load balancer: the staging names from
// environment-stage.tf (hackforla/devops#237), and the production names from
// environment-prod.tf and the bare domain below (hackforla/devops#238). Records that exist
// only for the old hosting are removed by later tickets in the hackforla/incubator#284
// epic, not here. What each record is: hackforla/devops#236.
//
// bastion.foodoasis.net was deliberately not copied. It pointed at an address that none of
// our accounts holds and served nothing. See hackforla/incubator#283.

resource "aws_route53_zone" "this" {
  name = "foodoasis.net"

  // The provider defaults this attribute to "Managed by Terraform".
  comment = "foodoasis.net - Food Oasis. Copied from Z05347102APWJD0S0P604 (account 470363915259), hackforla/incubator#283"

  // Destroying a hosted zone discards its delegation NS set. A recreated zone gets
  // different nameservers, so the outage is not recoverable from Terraform.
  lifecycle {
    prevent_destroy = true
  }
}

// The bare domain is served by the production service directly, like homeunite.us. Until
// hackforla/devops#238 it pointed at the Amplify app food-oasis-client in the Food Oasis
// account, which only redirected it to www; hackforla/devops#239 deletes that app. The load
// balancer is IPv4 only, so there is no AAAA alias.
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "foodoasis.net"
  type    = "A"

  alias {
    name                   = data.aws_lb.incubator.dns_name
    zone_id                = data.aws_lb.incubator.zone_id
    evaluate_target_health = false
  }
}

// Validated the Amplify-managed certificate that served https://foodoasis.net until
// hackforla/devops#238 moved the bare domain off Amplify. No longer needed; removed with the
// Amplify app in hackforla/devops#239.
resource "aws_route53_record" "acm_validation_amplify" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "_2f61d85f906770417af6d5152488d87c.foodoasis.net"
  type    = "CNAME"
  ttl     = 500
  records = ["_024c2f00cf0d3f5b1f419defa4b507a4.rlltrpyzyf.acm-validations.aws."]
}

// Validates two certificates in the Food Oasis account that expired in 2022
// (*.foodoasis.net in us-west-2, foodoasis.net in us-west-1). Dead, but copied so the
// nameserver switch is an exact copy.
resource "aws_route53_record" "acm_validation_expired" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "_df4e76804a0bef706749d86f1ac19f02.foodoasis.net"
  type    = "CNAME"
  ttl     = 300
  records = ["_42feb58cb16fa888f9b9a178c2e627a3.bsgbmzkfwj.acm-validations.aws."]
}

// The Heroku apps' remaining custom domains. Every domain added to Heroku gets its own
// *.herokudns.com target. devmckinney's target no longer resolves, so it is attached to no
// app. Both are removed in hackforla/devops#239. The staging names that were here moved to
// environment-stage.tf in hackforla/devops#237, and the production names to
// environment-prod.tf in hackforla/devops#238.
locals {
  foodoasis_net_heroku = {
    "devmckinney" = { target = "vascular-crayfish-aj27rkpig2e49kvhsw1c4x2x.herokudns.com", ttl = 300 }
    "vitela"      = { target = "genetic-beet-t67ml71w9czsmnaf6n76jijs.herokudns.com", ttl = 300 }
  }

  // SES Easy DKIM tokens for the foodoasis.net identity in the Food Oasis account. Heroku's
  // mail is signed with them until production cuts over. The tokens are literal values here,
  // so for_each can plan them.
  foodoasis_net_ses_dkim = toset([
    "akv3qdwjndzyztkwl2kh5slsgu6rodxg",
    "ccguoglf4e4dagy6bnpnbu4wbef5vz5e",
    "eakcolzxbdawmglftoym374nj5rvpdjf",
    "gce7jwtruz6qsygrlocxalfjevshgcl7",
    "vwgbthmf6niyuj6o4nrdsmua3k6rmh73",
    "zokamefd2myjiijghx5bx5cptukwrkba",
  ])

  // SendGrid domain authentication and link branding. Leftovers: email moved to SES in
  // January 2026 (hackforla/food-oasis#2629).
  foodoasis_net_sendgrid = {
    "20051064"      = "sendgrid.net"
    "url4544"       = "sendgrid.net"
    "em5870"        = "u20051064.wl065.sendgrid.net"
    "s1._domainkey" = "s1.domainkey.u20051064.wl065.sendgrid.net"
    "s2._domainkey" = "s2.domainkey.u20051064.wl065.sendgrid.net"
  }
}

resource "aws_route53_record" "heroku" {
  for_each = local.foodoasis_net_heroku

  zone_id = aws_route53_zone.this.zone_id
  name    = "${each.key}.foodoasis.net"
  type    = "CNAME"
  ttl     = each.value.ttl
  records = [each.value.target]
}

resource "aws_route53_record" "ses_dkim" {
  for_each = local.foodoasis_net_ses_dkim

  zone_id = aws_route53_zone.this.zone_id
  name    = "${each.key}._domainkey.foodoasis.net"
  type    = "CNAME"
  ttl     = 1800
  records = ["${each.key}.dkim.amazonses.com"]
}

resource "aws_route53_record" "sendgrid" {
  for_each = local.foodoasis_net_sendgrid

  zone_id = aws_route53_zone.this.zone_id
  name    = "${each.key}.foodoasis.net"
  type    = "CNAME"
  ttl     = 300
  records = [each.value]
}

resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "_dmarc.foodoasis.net"
  type    = "TXT"
  ttl     = 300
  records = ["v=DMARC1; p=none;"]
}
