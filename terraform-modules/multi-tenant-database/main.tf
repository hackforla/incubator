resource "aws_lambda_function" "create_db" {
  count = var.create_db_instance ? 1 : 0

  filename      = "lambda.zip"
  function_name = "${local.envname}_multi-tenant-db"
  role          = aws_iam_role.this.arn
  handler       = "database.lambda_handler"
  runtime       = "python3.8"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  layers = [aws_lambda_layer_version.python-sqlalchemy.arn]
  
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

resource "aws_lambda_layer_version" "python-sqlalchemy" {
  filename   = "sqlalchemy.zip"
  layer_name = "sqlalchemy"

  compatible_runtimes = ["python3.8"]
}
