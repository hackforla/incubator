moved {
  from = aws_lb.alb
  to   = module.alb.aws_lb.alb
}
moved {
  from = aws_lb_listener.http_redirect
  to   = module.alb.aws_lb_listener.http_redirect
}
moved {
  from = aws_lb_listener.ssl
  to   = module.alb.aws_lb_listener.ssl
}
moved {
  from = aws_lb_listener_certificate.example["arn:aws:acm:us-west-2:035866691871:certificate/4db5d979-9797-4689-a9e9-58b7ac55c79d"]
  to   = module.alb.aws_lb_listener_certificate.example["arn:aws:acm:us-west-2:035866691871:certificate/4db5d979-9797-4689-a9e9-58b7ac55c79d"]
}
moved {
  from = aws_security_group.alb
  to   = module.alb.aws_security_group.alb
}
