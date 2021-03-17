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
  container_memory = var.container_memory == 0 ? 128 : var.container_memory
  task_cpu         = var.launch_type == "FARGATE" ? 256 : var.container_cpu == 0 ? null : var.container_cpu
  task_memory      = var.launch_type == "FARGATE" ? 512 : var.container_memory == 0 ? 128 : var.container_memory

  task_network_mode = var.launch_type == "FARGATE" ? "awsvpc" : "bridge"
  host_port         = var.launch_type == "FARGATE" ? var.container_port : 0
  target_type       = var.launch_type == "FARGATE" ? "ip" : "instance"
}

resource "aws_ecs_task_definition" "task" {
  family = local.task_definition_family

  container_definitions = templatefile(
    "${path.module}/templates/task-definition.json",
    {
      envapp = local.envname
      region = var.region
      application_type = var.application_type
      host_port          = local.host_port
      container_memory   = local.container_memory
      container_cpu      = var.container_cpu
      container_port     = var.container_port
      container_name     = local.container_name
      image              = var.container_image
      container_env_vars = jsonencode(local.env_vars)
    }
  )

  requires_compatibilities = ["EC2", "FARGATE"]
  network_mode             = local.task_network_mode
  execution_role_arn       = var.task_execution_role_arn
  memory                   = local.task_memory
  cpu                      = local.task_cpu
}

// Create group for streaming application logs
resource "aws_cloudwatch_log_group" "cwlogs" {
  name = "ecs/${local.envname}"
  retention_in_days = 14
}