resource "aws_lambda_function" "test_lambda" {
  count = var.create_db_instance ? 1 : 0

  filename      = "lambda.zip"
  function_name = "lamda_test_hello"
  role          = aws_iam_role.this.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  vpc_config {
    subnet_ids         = local.db_subnet_ids
    security_group_ids = [aws_security_group.this.id]
  }

  environment {
    variables = {
      FOO = "BAR"
    }
  }

  tags = var.tags
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "files"
  output_path = "lambda.zip"
}
