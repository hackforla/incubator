variable "project_name" {
  type = string
}

variable "repository_name" {
  type = string
}

output "role_name" {
  value = aws_iam_role.builder.name
}