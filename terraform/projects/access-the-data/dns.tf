// accessthedata.org. DNS only. The project's ECS service, Cloud Map namespace and
// private zone were removed in August 2026; what is left is a GitHub Pages site
// served from hackforla/access-the-data. The zone is still live and delegated --
// do not read the absence of compute as an abandoned zone.
// See hackforla/incubator#183.

resource "aws_route53_zone" "this" {
  name = "accessthedata.org"

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

// GitHub Pages apex addresses, per
// https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site#configuring-an-apex-domain
// TTL is 3600 here rather than the 300 used in the other zones. Adopted as found.
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "accessthedata.org"
  type    = "A"
  ttl     = 3600
  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

resource "aws_route53_record" "apex_ipv6" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "accessthedata.org"
  type    = "AAAA"
  ttl     = 3600
  records = [
    "2606:50c0:8000::153",
    "2606:50c0:8001::153",
    "2606:50c0:8002::153",
    "2606:50c0:8003::153",
  ]
}

// DNS validation for the ACM certificate accessthedata.org
// (arn:...:certificate/b92e46ff-9296-464b-b39d-e61f48b90fb0). Deleting this stops
// the certificate renewing. It is declared standalone here because the certificate
// itself is not yet in Terraform; when it is imported this record should move to a
// for_each over the certificate's domain_validation_options and this resource
// removed. See hackforla/incubator#183.
resource "aws_route53_record" "cert_validation" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "_0cf1f0f2546b74cb244e41df3c73afe6.accessthedata.org"
  type    = "CNAME"
  ttl     = 60
  records = ["_f6e79d0bd5ddcd952dae00479b8d4a1c.cmqshkkvmc.acm-validations.aws."]
}
