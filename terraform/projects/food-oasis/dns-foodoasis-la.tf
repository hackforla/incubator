// foodoasis.la. This zone starts as a copy of the live Cloudflare zone, so moving the
// domain's nameservers here changes nothing anyone can see except the bare domain.
// Cloudflare points the bare domain at Heroku with a CNAME at the zone root, which Route 53
// cannot do, so here it is an alias to the load balancer, which redirects it to www (the
// listener rule below). What each record is: hackforla/devops#236.
//
// search, staging, vote and mail were deliberately not copied. None of them serves
// anything. See hackforla/incubator#285.

resource "aws_route53_zone" "foodoasis_la" {
  name = "foodoasis.la"

  // The provider defaults this attribute to "Managed by Terraform".
  comment = "foodoasis.la - Food Oasis. Copied from Cloudflare, hackforla/incubator#285"

  // Destroying a hosted zone discards its delegation NS set. A recreated zone gets
  // different nameservers, so the outage is not recoverable from Terraform.
  lifecycle {
    prevent_destroy = true
  }
}

data "aws_lb" "incubator" {
  name = "incubator-prod-lb"
}

data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.incubator.arn
  port              = 443
}

// The load balancer is IPv4 only, so there is no AAAA alias. Cloudflare answered AAAA for
// this name only because it proxied it. hackforla/devops#238 keeps this alias and points
// the bare domain at the production service instead of the redirect.
resource "aws_route53_record" "foodoasis_la_apex" {
  zone_id = aws_route53_zone.foodoasis_la.zone_id
  name    = "foodoasis.la"
  type    = "A"

  alias {
    name                   = data.aws_lb.incubator.dns_name
    zone_id                = data.aws_lb.incubator.zone_id
    evaluate_target_health = false
  }
}

// Heroku production. Heroku holds its own certificate for this name, so it keeps working
// without Cloudflare's proxy in front. hackforla/devops#238 points it at the load balancer.
resource "aws_route53_record" "foodoasis_la_www" {
  zone_id = aws_route53_zone.foodoasis_la.zone_id
  name    = "www.foodoasis.la"
  type    = "CNAME"
  ttl     = 300
  records = ["agile-amphibian-bjldl1n87xlxb75r57ri5epb.herokudns.com"]
}

// @foodoasis.la email is hosted by Zoho. These three records are copied unchanged.
resource "aws_route53_record" "foodoasis_la_mx" {
  zone_id = aws_route53_zone.foodoasis_la.zone_id
  name    = "foodoasis.la"
  type    = "MX"
  ttl     = 300
  records = ["10 mx.zoho.com", "20 mx2.zoho.com"]
}

resource "aws_route53_record" "foodoasis_la_txt" {
  zone_id = aws_route53_zone.foodoasis_la.zone_id
  name    = "foodoasis.la"
  type    = "TXT"
  ttl     = 300
  records = [
    "v=spf1 include:zoho.com ~all",
    "google-site-verification=tyXNoLKw2VjgRglbyodhn048nLisVaCQRTIZDHWmcbw",
  ]
}

resource "aws_route53_record" "foodoasis_la_zoho_dkim" {
  zone_id = aws_route53_zone.foodoasis_la.zone_id
  name    = "zoho._domainkey.foodoasis.la"
  type    = "TXT"
  ttl     = 300
  records = ["v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCdaiH0QCqMMD3Pbwp098rnWi7ydT8hcZUIwhs4+9gI6us5h54sqtTWFbSJUthQURzTcyau14qRFr1a+nj42t6foA4eSBNsSLLtIDkmlMo1LQhBjuS5hz1Ss+GJz0Gu+2wIZKWETP29AhR+6gONxraMoTcV/laoBCdYrIy1m6T3fQIDAQAB"]
}

// Temporary. Keeps the bare domain working while www is still on Heroku, by sending it
// there. hackforla/devops#238 removes this rule; until then it wins over the production
// service's rule 601.
resource "aws_lb_listener_rule" "foodoasis_la_redirect" {
  listener_arn = data.aws_lb_listener.https.arn
  priority     = 599

  condition {
    host_header {
      values = ["foodoasis.la"]
    }
  }

  action {
    type = "redirect"

    redirect {
      host        = "www.foodoasis.la"
      path        = "/#{path}"
      query       = "#{query}"
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_302"
    }
  }
}
