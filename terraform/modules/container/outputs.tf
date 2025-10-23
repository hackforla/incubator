output "task_role_arn" {
  description = "ARN of the task role that this container uses. Good for setting up permissions like s3 access"
  value = aws_iam_role.instance.arn
}

output "task_role_name" {
  description = "IAM role name of the task role that this container uses."
  value = aws_iam_role.instance.name
}