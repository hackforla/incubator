output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "ecs_asg_arn" {
  value = module.asg.this_autoscaling_group_arn
}

output "asg_capacity_prov" {
  value = aws_ecs_capacity_provider.prov1.name
}

output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}