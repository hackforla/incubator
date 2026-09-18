output "task_role_arn" {
  description = "ARN of the task role that this container uses. This is the role application code runs as, and the place project-specific AWS permissions go. See [Container Permissions](https://github.com/hackforla/incubator/wiki/Container-Permissions) on the incubator wiki for what it already grants and how to add to it."
  value = aws_iam_role.instance.arn
}

output "task_role_name" {
  description = "IAM role name of the task role that this container uses."
  value = aws_iam_role.instance.name
}

output "execution_role_arn" {
  description = "ARN of the execution role generated for this container. It pulls the image, writes logs and reads secrets, scoped to this container's project."
  value = aws_iam_role.execution.arn
}

output "execution_role_name" {
  description = "IAM role name of the execution role generated for this container."
  value = aws_iam_role.execution.name
}