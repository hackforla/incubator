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

module "ecs-task" {
  for_each = var.containers

  source               = "../ecs-task"
  shared_configuration = var.shared_configuration

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
  container_port    = each.value.port
  container_env_vars = each.value.db_access ? merge({
    SQL_USER     = postgresql_role.db_owner[0].name
    SQL_DATABASE = postgresql_database.db[0].name
    SQL_HOST     = data.aws_db_instance.shared.address
    SQL_PORT     = 5432
  }, each.value.env_vars) : each.value.env_vars
  container_secrets = each.value.db_access ? {
    SQL_PASSWORD = aws_ssm_parameter.rds_dbowner_password.arn
  } : {}
}
