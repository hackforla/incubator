locals {
  envappname = "${var.project_name}-${var.application_type}-${var.environment}"

  # Conditionals for container compute resources
  # 0 CPU means unlimited cpu access
  # 0 memory is invalid, thus it defaults to 128mb
  container_cpu    = var.launch_type == "FARGATE" ? var.container_cpu : var.container_cpu == 0 ? 128 : var.container_cpu
  container_memory = var.launch_type == "FARGATE" ? var.container_memory : var.container_memory == 0 ? 256 : var.container_memory

  task_cpu    = var.launch_type == "FARGATE" ? var.container_cpu : var.container_cpu == 0 ? null : var.container_cpu
  task_memory = var.launch_type == "FARGATE" ? var.container_memory : var.container_memory == 0 ? 128 : var.container_memory

  task_network_mode = var.launch_type == "FARGATE" ? "awsvpc" : "bridge"
  host_port         = var.launch_type == "FARGATE" ? var.container_port : 0
  target_type       = var.launch_type == "FARGATE" ? "ip" : "instance"

  public_address = length(var.host_names) > 0
}

module "application_container_def" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.56.0"

  container_name               = local.envappname
  container_image              = var.container_image
  container_cpu                = var.container_cpu
  container_memory_reservation = local.container_memory
  port_mappings = [
    {
      containerPort = var.container_port
      hostPort      = local.host_port
      protocol      = "tcp"
    }
  ]
  map_environment = var.container_env_vars
  map_secrets     = var.container_secrets

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = var.log_group
      awslogs-region        = var.region
      awslogs-stream-prefix = var.application_type
    }
  }
  linux_parameters = {
    initProcessEnabled = true
    capabilities       = null
    devices            = null
    maxSwap            = null
    sharedMemorySize   = null
    swappiness         = null
    tmpfs              = null
  }
}

resource "aws_ecs_task_definition" "task" {
  family = local.envappname

  container_definitions = jsonencode([
    module.application_container_def.json_map_object
  ])

  requires_compatibilities = [var.launch_type]
  network_mode             = local.task_network_mode
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.task_role_arn
  memory                   = local.task_memory
  cpu                      = local.task_cpu
}


resource "aws_lb_target_group" "this" {
  count = local.public_address ? 1 : 0

  target_type          = local.target_type
  name                 = local.envappname
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.shared_configuration.vpc_id
  deregistration_delay = 5
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    path                = var.health_check_path
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
  count = local.public_address ? 1 : 0

  listener_arn = var.shared_configuration.alb_https_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  condition {
    host_header {
      values = var.host_names
    }
  }

  # Path Pattern condition
  dynamic "condition" {
    for_each = length(var.path_patterns) == 0 ? [] : [var.path_patterns]

    content {
      path_pattern {
        values = var.path_patterns
      }
    }
  }
}
resource "aws_ecs_service" "ec2" {
  count                  = var.launch_type == "FARGATE" ? 0 : 1
  name                   = local.envappname
  cluster                = var.shared_configuration.cluster_id
  enable_execute_command = true
  task_definition        = aws_ecs_task_definition.task.arn
  launch_type            = var.launch_type
  desired_count          = var.desired_count

  dynamic "load_balancer" {
    for_each = local.public_address ? [1] : []
    content {
      container_name   = local.envappname
      container_port   = var.container_port
      target_group_arn = aws_lb_target_group.this[0].arn
    }
  }

  depends_on = [aws_lb_listener_rule.static] // XXX put into module refs

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_service" "fargate" {
  count                  = var.launch_type == "FARGATE" ? 1 : 0
  name                   = local.envappname
  cluster                = var.shared_configuration.cluster_id
  enable_execute_command = true
  task_definition        = aws_ecs_task_definition.task.arn
  launch_type            = var.launch_type
  desired_count          = var.desired_count

  network_configuration {
    subnets          = var.shared_configuration.public_subnet_ids
    security_groups  = [var.fargate_security_group_id]
    assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each = local.public_address ? [1] : []
    content {
      container_name   = local.envappname
      container_port   = var.container_port
      target_group_arn = aws_lb_target_group.this[0].arn
    }
  }

  depends_on = [aws_lb_listener_rule.static]

  lifecycle {
    ignore_changes = [desired_count]
  }
}
