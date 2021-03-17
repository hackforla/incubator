resource "aws_ecs_service" "fargate" {
  count           = var.launch_type == "FARGATE" ? 1 : 0
  name            = local.envname
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = var.launch_type
  desired_count   = var.desired_count

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.fargate.id]
    assign_public_ip = true
  }

  load_balancer {
    container_name   = local.container_name
    container_port   = var.container_port
    target_group_arn = aws_lb_target_group.this.arn
  }

  depends_on = [aws_lb_target_group.this, aws_lb_listener_rule.static]
  
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_security_group" "fargate" {
  name        = "ecs_fargate_${local.envname}"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "All ingress from ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    description = "All Internal traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ecs_container_instance_${local.envname}" }
}