variable "project_name" {
  type        = string
  description = "HfLA project name (vrms, home-unite-us, etc)"
}

variable "repository_name" {
  type        = string
  description = "GitHub repository name, without any organizations or prefix - for example, `HomeUniteUs`"
}

output "role_name" {
  value       = aws_iam_role.builder.name
  description = "IAM role name that will be assumed by GitHub actions when running"
}

output "role_arn" {
  value       = aws_iam_role.builder.arn
  description = "IAM role ARN, for the `role-to-assume` input of `aws-actions/configure-aws-credentials`"
}
