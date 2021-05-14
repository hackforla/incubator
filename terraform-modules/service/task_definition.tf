locals {
  env_vars = [
    for k, v in var.container_env_vars : {
      "name" : k,
      "value" : v
    }
  ]

  # Conditional Intellegience for container compute resources
  # 0 CPU means unlimited cpu access
  # 0 memory is invalid, thus it defaults to 128mb
  container_cpu    = var.launch_type == "FARGATE" ? var.container_cpu : var.container_cpu == 0 ? 128 : var.container_cpu
  container_memory = var.launch_type == "FARGATE" ? var.container_memory : var.container_memory == 0 ? 256 : var.container_memory

  task_cpu    = var.launch_type == "FARGATE" ? var.container_cpu : var.container_cpu == 0 ? null : var.container_cpu
  task_memory = var.launch_type == "FARGATE" ? var.container_memory : var.container_memory == 0 ? 128 : var.container_memory

  task_network_mode = var.launch_type == "FARGATE" ? "awsvpc" : "bridge"
  host_port         = var.launch_type == "FARGATE" ? var.container_port : 0
  target_type       = var.launch_type == "FARGATE" ? "ip" : "instance"
}

module "application_container_def" {
  source            = "cloudposse/ecs-container-definition/aws"
  version           = "0.56.0"

  container_name    = local.envappname
  container_image   = var.container_image
  container_cpu               = var.container_cpu
  container_memory_reservation = local.container_memory
  port_mappings = [
    {
      containerPort = var.container_port
      hostPort      = local.host_port
      protocol      = "tcp"
    }
  ]
  map_environment = var.container_env_vars
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = format("ecs/%s", local.envname)
      awslogs-region        = var.region
      awslogs-stream-prefix = var.application_type
    }
  }
}

resource "aws_ecs_task_definition" "task" {
  family = local.envappname

  container_definitions = jsonencode([
    module.application_container_def.json_map_object
  ])

  requires_compatibilities = [var.launch_type]
  network_mode             = local.task_network_mode
  task_role_arn       = var.task_execution_role_arn
  execution_role_arn       = var.task_execution_role_arn
  memory                   = local.task_memory
  cpu                      = local.task_cpu
}

// Create group for streaming application logs
resource "aws_cloudwatch_log_group" "cwlogs" {
  name              = "ecs/${local.envname}"
  retention_in_days = 14
}
