resource "aws_lb_target_group" "this" {
  target_type          = local.target_type
  name                 = "${local.envname}-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 90
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    interval            = 15
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200,302"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = var.alb_https_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = var.host_names
    }
  }

  depends_on = [aws_lb_target_group.this]
}
