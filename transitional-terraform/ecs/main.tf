#----- ECS --------
resource "aws_ecs_cluster" "cluster" {
  name = local.envname

  capacity_providers = ["FARGATE", aws_ecs_capacity_provider.this.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 100
  }

  tags = var.tags
}

resource "aws_ecs_capacity_provider" "this" {
  name = local.envname

  auto_scaling_group_provider {
    auto_scaling_group_arn = module.asg.autoscaling_group_arn
  }

  tags = var.tags

  // depends_on = [aws_iam_service_linked_role.ecs]
}
