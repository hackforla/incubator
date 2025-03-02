output "task_role_arn" {
  value = aws_iam_role.instance.arn
}

output "task_role_name" {
  value = aws_iam_role.instance.name
}