
data "aws_route53_zone" "this" {
  zone_id = var.zone_id
} 


data "aws_lb" "this" {
  arn  = "arn:aws:elasticloadbalancing:us-west-2:035866691871:loadbalancer/app/incubator-prod-lb/7451adf77133ef36"
}



resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = data.aws_route53_zone.this.name
  type    = "A"
  ttl     = 300

  alias {
    name = data.aws_lb.this.dns_name
    zone_id = data.aws_lb.this.zone_id
    evaluate_target_health = false
  }
}