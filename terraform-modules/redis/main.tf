data "template_file" "container-definition" {
  template = file("./templates/container-definition.json")
  vars     = {
    container_name   = local.container_name
    container_cpu    = var.container_cpu
    container_memory = var.container_memory == 0 ? 85 : var.container_memory
  }
}

resource "aws_ecs_task_definition" "task" {
  family = local.task_definition_family

  container_definitions    = data.template_file.container-definition.rendered
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  memory                   = var.container_memory == 0 ? null : var.container_memory
  cpu                      = var.container_cpu == 0 ? null : var.container_cpu
  tags                     = var.tags
}

resource "aws_ecs_service" "svc" {
  name            = local.ecs_service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "EC2"
  desired_count   = var.desired_count
  tags            = var.tags

  service_registries {
    registry_arn = aws_service_discovery_service.sd_service.arn
  }

  network_configuration {
    subnets         = var.public_subnet_ids
    security_groups = [aws_security_group.redis_sg.id]
  }

  depends_on = [aws_service_discovery_service.sd_service]
}

resource "aws_security_group" "redis_sg" {
  name        = "${var.resource_name}-${var.environment}-redis"
  description = "inbound from load balancer to ecs service"

  vpc_id = var.vpc_id

  ingress {
    description = "Allow all inbound redis connection - may change to only internal vpc only"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "outbound traffic to the world"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({ Name = "${var.resource_name}-${var.environment}-redis" }, var.tags)
}
