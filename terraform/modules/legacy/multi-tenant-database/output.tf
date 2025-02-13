output "lambda_function" {
  value = var.create_db_instance ? element(concat(aws_lambda_function.create_db.*.function_name, [""]), 0) : ""
}
