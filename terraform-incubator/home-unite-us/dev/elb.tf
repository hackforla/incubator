resource "aws_lb_target_group" "homeuniteus" {
  target_type          = "ip"
  name                 = local.app_name
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
  deregistration_delay = 5
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    path                = "/"
    interval            = 15
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200,302"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "homeuniteus" {
  listener_arn = local.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.homeuniteus.arn
  }

  condition {
    host_header {
      values = local.host_names
    }
  }

  # Path Pattern condition
  # dynamic "condition" {
  #   for_each = length(var.path_patterns) == 0 ? [] : [var.path_patterns]

  #   content {
  #     path_pattern {
  #       values = var.path_patterns
  #     }
  #   }
  # }
}
