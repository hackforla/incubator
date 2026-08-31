// homeunite.us. The apex, www and qa all resolve to incubator-prod-lb and are served
// by the production service in environment-prod.tf under listener rule 17 --
// qa.homeunite.us is the hostname baked into the application's Cognito redirect URI,
// so it is production despite the name. qa1.homeunite.us is declared by the dns-entry
// module in environment-qa.tf rather than here. See hackforla/incubator#183.
//
// dev.homeunite.us was an A record pointing at 18.223.160.58, a Terragrunt-era host
// that no longer exists -- it answers on neither port 80 nor 443 and holds no instance
// or Elastic IP in this account in any region. It was deleted in August 2026. The apex
// pointed at the same dead address and is repointed at the load balancer below.

resource "aws_route53_zone" "this" {
  name = "homeunite.us"

  // Left over from the Terragrunt platform, which set this string on the zones it
  // created. It happens to match the provider default. Stated explicitly so it is
  // not "cleaned up" into a diff against a live zone.
  comment = "Managed by Terraform"

  // Destroying a hosted zone discards its delegation NS set. A recreated zone gets
  // different nameservers, so the outage is not recoverable from Terraform.
  lifecycle {
    prevent_destroy = true
  }
}

// The apex is an alias to the load balancer, not a CNAME -- a zone apex cannot hold a
// CNAME. Z1H1FL5HABSF5 is the canonical hosted zone id of the us-west-2 ALB service,
// not of incubator-prod-lb itself. This record previously held the dead address
// 18.223.160.58; the apex is listed in the prod service's additional_host_urls so it
// reaches the application rather than the listener's default redirect.
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "homeunite.us"
  type    = "A"

  alias {
    name                   = "incubator-prod-lb-569274394.us-west-2.elb.amazonaws.com."
    zone_id                = "Z1H1FL5HABSF5"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "www.homeunite.us"
  type    = "CNAME"
  ttl     = 300
  records = ["incubator-prod-lb-569274394.us-west-2.elb.amazonaws.com"]
}

// Production, not a QA environment. The image is built with HUU_TARGET_ENV=qa and the
// application's COGNITO_REDIRECT_URI points here, so this name cannot be retired
// without rebuilding the image. See the notes in environment-prod.tf.
resource "aws_route53_record" "qa" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "qa.homeunite.us"
  type    = "CNAME"
  ttl     = 300
  records = ["incubator-prod-lb-569274394.us-west-2.elb.amazonaws.com"]
}

// The DNS validation record for the homeunite.us certificate used to be declared here. It
// moved to the acm-certificate module in certificate.tf, which owns the certificate, its
// validation records and its load balancer attachment together.
// See hackforla/incubator#185.
