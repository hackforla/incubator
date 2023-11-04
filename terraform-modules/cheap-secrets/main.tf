variable "secret-names" {
  type = list(string)
}

variable "length" {
  type    = number
  default = 48
}

data "aws_secretsmanager_random_password" "them" {
  for_each        = var.secret_names
  password_length = var.length
}

// We're using the random_password data source to initialize this;
// we use the lifecycle.ignore_changes to say that we don't want
// the value to be updated. We get most of the benefit of a
// Secret Manager entry, and save 0.40 USD/mo
resource "aws_ssm_parameter" "these" {
  for_each = var.secret_names
  name     = each.value
  type     = "SecureString"
  value    = data.aws_secretsmanager_random_password.them[each.value].random_password
  lifecycle {
    ignore_changes = [value]
  }
}

output "arn" {
  value = { for k, v in aws_ssm_parameter.these : k => v.arn }
}
