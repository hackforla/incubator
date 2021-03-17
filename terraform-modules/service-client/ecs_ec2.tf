
resource "aws_ecs_service" "ec2" {
  count           = var.launch_type == "FARGATE" ? 0 : 1
  name            = local.envname
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = var.launch_type
  desired_count   = var.desired_count

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