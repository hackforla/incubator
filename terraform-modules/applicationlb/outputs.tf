output "security_group_id" {
  value = aws_security_group.alb.id
}

output "lb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "lb_arn" {
  value = aws_lb.alb.arn
}

output "alb_target_group_arn" {
  value = aws_lb.alb.arn
}

output "alb_target_group_id" {
  value = aws_lb.alb.id
}

output "alb_https_listener_arn" {
  value = aws_lb_listener.ssl.arn
}