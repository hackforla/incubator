
provider "aws" {
  region = "us-west-2"
}


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


data "aws_vpc" "incubator" {
  id = local.vpc_id
}


# aws_ecs_task_definition.task:
resource "aws_ecs_task_definition" "homeuniteus" {
  container_definitions = jsonencode(
    [
      {
        cpu = 256
        environment = [{
          "name"  = "APP_ENVIRONMENT",
          "value" = "DEV"
        }]
        essential = true
        image     = "035866691871.dkr.ecr.us-west-2.amazonaws.com/homeuniteus:nginx-20241002.1"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "ecs/homeuniteus"
            awslogs-region        = "us-west-2"
            awslogs-stream-prefix = "app"
          }
        }
        memoryReservation = 512
        mountPoints       = []
        name              = "homeuniteus"
        portMappings = [
          {
            containerPort = 80
            protocol      = "tcp"
          },
        ]
        readonlyRootFilesystem = false
        volumesFrom            = []
      },
    ]
  )
  cpu                = "256"
  execution_role_arn = "arn:aws:iam::035866691871:role/incubator-prod-ecs-task-role"
  family             = "homeuniteus"
  memory             = "512"
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE",
  ]
  task_role_arn = "arn:aws:iam::035866691871:role/incubator-prod-ecs-task-role"
}


resource "aws_security_group" "homeuniteus" {
  name        = "ecs_fargate_${local.app_name}"
  description = "Allow TLS inbound traffic"
  vpc_id      = local.vpc_id

  ingress {
    description = "All Internal traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.incubator.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ecs_container_instance_${local.app_name}" }
}


resource "aws_ecs_service" "homeuniteus" {
  name                   = "homeuniteus"
  cluster                = "arn:aws:ecs:us-west-2:035866691871:cluster/incubator-prod"
  enable_execute_command = true
  task_definition        = aws_ecs_task_definition.homeuniteus.arn
  launch_type            = "FARGATE"
  desired_count          = 1

  network_configuration {
    subnets = [
      "subnet-03202f3bf9a24c1a5",
      "subnet-08c26edd1afc2b9d7",
    ]
    security_groups  = [aws_security_group.homeuniteus.id]
    assign_public_ip = true
  }

  load_balancer {
    container_name   = local.app_name
    container_port   = 80
    target_group_arn = aws_lb_target_group.homeuniteus.arn
  }

  depends_on = [aws_lb_target_group.homeuniteus, aws_lb_listener_rule.homeuniteus]

  lifecycle {
    ignore_changes = [desired_count]
  }
}


data "aws_lb" "incubator" {
  arn = local.lb_arn
}

# Resource for subdomain CNAME records
resource "aws_route53_record" "subdomain" {
  for_each = { for v in local.local.host_names : v => v }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value
  type    = "CNAME"
  ttl     = "300"
  records = [
    data.aws_lb.incubator.dns_name
  ]
}