// data "aws_lambda_invocation" "example" {
//   count = var.data ? 1 : 0
//   function_name = aws_lambda_function.test_lambda[count.index].function_name

//   input = <<JSON
// {
//   "db_host": "incubator-prod-database.ckkyjlg5wpvd.us-west-1.rds.amazonaws.com",
//   "db_password": "asioasjf"
// }
// JSON
// }

// output "result_entry" {
//   value = jsondecode(data.aws_lambda_invocation.example.result)
// }