data "aws_lambda_invocation" "this" {
  count = lookup(var.postgres_database, "database_username", "") != "" ? 1 : 0
  function_name = var.lambda_function

  input = jsonencode({
    db_host = var.db_instance_endpoint
    db_password = var.root_db_password
  })
}

output "result_entry" {
  value = element(concat(data.aws_lambda_invocation.this.*.result, [""]), 0)
}

// jsonencode({
//     db_host = var.db_instance_endpoint
//     db_password = var.root_db_password
//   })


// <<JSON
//   {
//     "db_host": "incubator-prod-database.ckkyjlg5wpvd.us-west-1.rds.amazonaws.com",
//     "db_password": "asioasjf"
//   }
//   JSON
