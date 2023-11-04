moved {
  from = aws_route53_record.apex
  to   = module.zone.aws_route53_record.apex
}
moved {
  from = aws_route53_zone.this
  to   = module.zone.aws_route53_zone.this
}
