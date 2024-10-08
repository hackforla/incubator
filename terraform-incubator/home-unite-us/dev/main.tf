provider "aws" {
  region = "us-west-2"
}

// Create group for streaming application logs
resource "aws_cloudwatch_log_group" "cwlogs" {
  name              = "ecs/homeuniteus"
  retention_in_days = 14
}

data "aws_vpc" "incubator" {
  id = local.vpc_id
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}

resource "aws_iam_role_policy_attachment" "lambda_cognito" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
  role       = aws_iam_role.lambda.name
}

data "archive_file" "cognito_custom_message" {
  type        = "zip"
  source_file = "./src/customMessage.js"
  output_path = "customMessage.zip"
}

resource "aws_lambda_function" "cognito_custom_message" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "customMessage.zip"
  function_name = "customMessage"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  architectures                      = ["x86_64"]

  source_code_hash = data.archive_file.cognito_custom_message.output_base64sha256

  runtime = "nodejs18.x"

}

data "archive_file" "cognito_merge_users" {
  type        = "zip"
  source_file = "./src/mergeUsers.py"
  output_path = "mergeUsers.zip"
}

resource "aws_lambda_function" "cognito_merge_users" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "mergeUsers.zip"
  function_name = "mergeUsers"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.cognito_merge_users.output_base64sha256

  runtime = "python3.12"

}

resource "aws_iam_role" "cognito_idp" {
  name = "homeuniteus-cognito-idp"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "",
        Effect = "Allow",
        Principal = {
          Service = "cognito-idp.amazonaws.com"
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "f027bce1-d945-40d4-8b59-54e12015cdb7"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "main" {
  name = "homeuniteus-cognito-idp"
  role = aws_iam_role.cognito_idp.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:publish"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_cognito_user_pool" "homeuniteus" {
  mfa_configuration          = "OPTIONAL"
  name                       = "Home Unite Us"
  username_attributes        = ["email", "phone_number"]
  auto_verified_attributes   = ["email"]
  deletion_protection        = "ACTIVE"
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  email_configuration {
    email_sending_account  = "COGNITO_DEFAULT"
  }
  lambda_config {
    custom_message                 = aws_lambda_function.cognito_custom_message.arn
    pre_sign_up                    = aws_lambda_function.cognito_merge_users.arn
  }
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true
    string_attribute_constraints {
      max_length = jsonencode(2048)
      min_length = jsonencode(0)
    }
  }
  sms_configuration {
    external_id    = "f027bce1-d945-40d4-8b59-54e12015cdb7"
    sns_caller_arn = aws_iam_role.cognito_idp.arn
    sns_region     = "us-west-2"
  }
  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }
  username_configuration {
    case_sensitive = false
  }
  verification_message_template {
    default_email_option  = "CONFIRM_WITH_CODE"
  }
}