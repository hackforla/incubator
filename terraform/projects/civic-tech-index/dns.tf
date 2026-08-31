// civictechindex.org. The apex is an S3 website bucket; api and api-stage reach
// incubator-prod-lb. Note the apex serves over plain HTTP only -- S3 website endpoints
// do not support TLS, which is a property of the hosting choice rather than a missing
// record. See hackforla/incubator#183.
//
// test.civictechindex.org pointed at the load balancer with no listener rule behind it,
// so it only ever reached the default redirect to www.hackforla.org. It was deleted in
// August 2026, along with stage.api.civictechindex.org -- see environment-stage.tf.

resource "aws_route53_zone" "this" {
  name = "civictechindex.org"

  // The live zone has an empty comment. The provider defaults this attribute to
  // "Managed by Terraform", so omitting it would plan a change against a live zone.
  comment = ""

  // Destroying a hosted zone discards its delegation NS set. A recreated zone gets
  // different nameservers, so the outage is not recoverable from Terraform.
  lifecycle {
    prevent_destroy = true
  }
}

// Alias to the S3 website endpoint, not to the bucket. Z3BJ6K6RIION7M is the hosted
// zone id of the us-west-2 S3 website service. The bucket moved from us-west-1 to
// us-west-2 in August 2026 and this record was converted from a plain A record at
// 52.219.116.83 to the alias below at the same time.
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "civictechindex.org"
  type    = "A"

  alias {
    name                   = "s3-website-us-west-2.amazonaws.com."
    zone_id                = "Z3BJ6K6RIION7M"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "api.civictechindex.org"
  type    = "CNAME"
  ttl     = 300
  records = ["incubator-prod-lb-569274394.us-west-2.elb.amazonaws.com"]
}

resource "aws_route53_record" "api_stage" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "api-stage.civictechindex.org"
  type    = "CNAME"
  ttl     = 300
  records = ["incubator-prod-lb-569274394.us-west-2.elb.amazonaws.com"]
}

// DNS validation for the ACM certificate *.civictechindex.org
// (arn:...:certificate/4db5d979-9797-4689-a9e9-58b7ac55c79d), attached to
// incubator-prod-lb. Moves to the certificate resource when ACM comes into Terraform.
resource "aws_route53_record" "cert_validation" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "_9aed66007870880679080f7176758008.civictechindex.org"
  type    = "CNAME"
  ttl     = 300
  records = ["_5f8c553c390792dc338365781f5ccc8e.zzxlnyslwt.acm-validations.aws."]
}
