locals {
  secret_name = "/${var.project_name}/${var.application_type}-${var.environment}-${var.name}"
}

resource "random_password" "password" {
  length           = var.length
  special          = true
  override_special = "!#$-"
}


resource "aws_ssm_parameter" "this" {
  name     = local.secret_name
  type     = "SecureString"
  value    = random_password.password.result
}

output "arn" {
  value = aws_ssm_parameter.this.arn
}

output "value" {
  value = random_password.password.result
  sensitive = true
}