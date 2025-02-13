resource "aws_ecr_repository" "these" {
  for_each             = var.containers
  name                 = "${var.project_name}-${var.application_type}-${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

// Create group for streaming application logs
resource "aws_cloudwatch_log_group" "cwlogs" {
  name              = "ecs/${local.envappname}"
  retention_in_days = 14
}


data "aws_route53_zone" "this" {
  zone_id = var.zone_id
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name        = "${local.envname}-ecs-task-role"
  description = "Allow ECS tasks to access AWS resources"

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

  inline_policy {
    name = "ecs-executor-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "ssm:GetParameters"
          Effect   = "Allow"
          Resource = flatten([for k, v in var.containers : values(v.secrets)])
        }
      ]
    })
  }

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


module "ecs-task" {
  for_each = var.containers

  service_discovery_dns_namespace_id = aws_service_discovery_private_dns_namespace.internal.id

  source               = "../ecs-task"
  shared_configuration = var.shared_configuration

  task_role_arn             = aws_iam_role.ecs_task_execution_role.arn
  fargate_security_group_id = aws_security_group.fargate.id
  project_name              = var.project_name
  environment               = var.environment
  region                    = var.region
  application_type          = each.key

  container_image  = "${aws_ecr_repository.these[each.key].repository_url}:${each.value.tag}"
  launch_type      = each.value.launch_type
  desired_count    = each.value.desired_count
  container_cpu    = each.value.cpu
  container_memory = each.value.memory

  host_names        = [for s in each.value.subdomains : "${s}.${data.aws_route53_zone.this.name}"]
  path_patterns     = each.value.path_patterns
  health_check_path = each.value.health_check_path
  log_group         = aws_cloudwatch_log_group.cwlogs.name
  container_port    = each.value.port
  container_env_vars = merge(each.value.env_vars, {
    SERVICE_DISCOVERY_DOMAIN = local.discovery_domain
  })
  container_secrets = each.value.secrets
}
