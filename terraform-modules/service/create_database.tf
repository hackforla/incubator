data "aws_lambda_invocation" "this" {
  count         = lookup(var.postgres_database, "database_username", "") != "" ? 1 : 0
  function_name = var.lambda_function

  input = jsonencode({
    db_host          = var.db_instance_endpoint
    root_db_username = var.root_db_username
    root_db_password = var.root_db_password
    new_db           = lookup(var.postgres_database, "database_name")
    new_db_user      = lookup(var.postgres_database, "database_username")
    new_db_password  = lookup(var.postgres_database, "database_password")
  })
}

output "result_entry" {
  value = element(concat(data.aws_lambda_invocation.this.*.result, [""]), 0)
}
