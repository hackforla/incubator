output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "ecs_asg_arn" {
  value = module.asg.autoscaling_group_arn
}

output "asg_capacity_prov" {
  value = aws_ecs_capacity_provider.this.name
}

output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

data "aws_caller_identity" "current" {}
output "default_ecs_service_role_arn" {
  value = format("arn:aws:iam::%s:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS", data.aws_caller_identity.current.account_id)
}
