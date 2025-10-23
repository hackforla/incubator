/**
 * # container
 *
 * This module sets up a running container within ECS. This could be a backend, frontend,
 * or fullstack container
 * 
 * Some things to watch out for:
 * 1. `listener_priority` - determines the order that load balancer rules run in when
 * forwarding traffic to the service. If you have a backend that runs with the path `/api/v1`,
 * and a frontend that just runs with `/`, make sure that the backend has a lower listener
 * priority than the frontend, otherwise all traffic will be sent to the frontend.
 */

// terraform-docs-ignore


locals {
  envappname = "${var.project_name}-${var.application_type}-${var.environment}"

  # Conditionals for container compute resources
  # 0 CPU means unlimited cpu access
  # 0 memory is invalid, thus it defaults to 128mb
  container_cpu    = var.container_cpu 
  container_memory = var.container_memory

  task_cpu    = var.container_cpu
  task_memory = var.container_memory

  task_network_mode = "awsvpc"
  target_type       = "ip"

  hostname_array = concat([var.hostname], var.additional_host_urls)
}

// security group for the container
// ingress of the provided port, unlimited egress
resource "aws_security_group" "container" {
  name        = "ecs-container-${local.envappname}"
  description = "Container ${local.envappname}"
  vpc_id      = "vpc-0bec93a4d80243845"

  tags = {
    Name = "ecs-container-${local.envappname}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "container_ingress_port" {
  security_group_id = aws_security_group.container.id
  cidr_ipv4         = "10.10.0.0/16"
  from_port         = var.container_port
  ip_protocol       = "tcp"
  to_port           = var.container_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.container.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



resource "aws_lb_target_group" "this" {
  name        = "${local.envappname}-tg"
  port        = var.container_port
  deregistration_delay = 10
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "vpc-0bec93a4d80243845"

  target_health_state {
    enable_unhealthy_connection_termination = false
  }

  health_check {
    matcher = "200,400,404"
    path = var.health_check_path == "" ? "" : var.health_check_path
  }

}

resource "aws_lb_listener_rule" "static" {
  listener_arn = "arn:aws:elasticloadbalancing:us-west-2:035866691871:listener/app/incubator-prod-lb/7451adf77133ef36/390a225766a4daf3"
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  depends_on = [ aws_lb_target_group.this ]

  condition {
    path_pattern {
      values = [var.path]
    }
  }

  condition {
    host_header {
      values = local.hostname_array
    }
  }
}


// IAM role for the container
resource "aws_iam_role" "instance" {
  name        = "ecs-container-${local.envappname}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_policy" "container_policy" {
  name        = "${var.project_name}-${var.application_type}-${var.environment}-task-policy"
  description = ""
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# enables:
#  aws ecs execute-command --cluster incubator-prod --container homeuniteus --task bea9b5813b5f42db8191b723ab9e6d9c --command /bin/bash --interactive
resource "aws_iam_role_policy_attachment" "task_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.container_policy.arn
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${local.envappname}"

  tags = {
  }
}

resource "aws_ecs_task_definition" "task" {
  family = local.envappname

  container_definitions = jsonencode([
    {
      name      = local.envappname
      image     = var.container_image
      cpu       = var.container_cpu
      memory    = var.container_memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group = aws_cloudwatch_log_group.this.name,
          awslogs-region = "us-west-2",
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = var.container_environment
      secrets = var.container_environment_secrets
      readonlyRootFilesystem = false
      initProcessEnabled     = true
    }
  ])

  requires_compatibilities = [ var.launch_type == "fargate" ? "FARGATE" : "EC2"]
  network_mode             = local.task_network_mode
  task_role_arn            = aws_iam_role.instance.arn
  execution_role_arn       = "arn:aws:iam::035866691871:role/incubator-prod-ecs-task-role"
  memory                   = local.task_memory
  cpu                      = local.task_cpu

}


resource "aws_ecs_service" "fargate" {
  count                  = 1
  name                   = local.envappname
  cluster                = "incubator-prod"
  enable_execute_command = true
  task_definition        = aws_ecs_task_definition.task.arn
  launch_type            = var.launch_type == "fargate" ? "FARGATE" : "EC2"
  desired_count          = 1

  network_configuration {
    subnets          = ["subnet-089e80a53e1522e28", "subnet-03ed55f60a6c28e72"]
    security_groups  = [aws_security_group.container.id]
  }


  lifecycle {
    ignore_changes = [desired_count]
  }

  load_balancer {
    container_name = local.envappname
    container_port = var.container_port
    target_group_arn = aws_lb_target_group.this.arn
  }
}
