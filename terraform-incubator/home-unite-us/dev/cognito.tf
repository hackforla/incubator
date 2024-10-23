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
  handler       = "customMessage.handler"
  architectures = ["x86_64"]

  source_code_hash = data.archive_file.cognito_custom_message.output_base64sha256

  runtime = "nodejs18.x"

}

data "archive_file" "cognito_merge_users" {
  type        = "zip"
  source_file = "./src/merge_users.py"
  output_path = "merge_users.zip"
}

resource "aws_lambda_function" "cognito_merge_users" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "merge_users.zip"
  function_name = "mergeUsers"
  role          = aws_iam_role.lambda.arn
  handler       = "merge_users.lambda_handler"

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
        Sid    = "",
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

resource "aws_lambda_permission" "allow_message_execution_from_user_pool" {
  statement_id  = "AllowMessageExecutionFromUserPool"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cognito_custom_message.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.homeuniteus.arn
}

resource "aws_lambda_permission" "allow_merge_execution_from_user_pool" {
  statement_id  = "AllowMergeExecutionFromUserPool"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cognito_merge_users.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.homeuniteus.arn
}

resource "aws_iam_role_policy" "cognito_sns" {
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
  mfa_configuration        = "OPTIONAL"
  name                     = "Home Unite Us"
  username_attributes      = ["email", "phone_number"]
  auto_verified_attributes = ["email"]
  deletion_protection      = "ACTIVE"
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
    email_sending_account = "COGNITO_DEFAULT"
  }
  lambda_config {
    custom_message = aws_lambda_function.cognito_custom_message.arn
    pre_sign_up    = aws_lambda_function.cognito_merge_users.arn
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
    default_email_option = "CONFIRM_WITH_CODE"
  }
}

locals {
  groups = [
    "Hosts",
    "Guests",
    "Coordinators",
    "Admins"
  ]
}

resource "aws_cognito_user_group" "homeuniteus" {
  for_each = toset(local.groups)
  name         = each.value
  user_pool_id = aws_cognito_user_pool.homeuniteus.id
  description  = "Managed by Terraform"
}

resource "aws_cognito_user_pool_domain" "homeuniteus" {
  domain       = "homeuniteus"
  user_pool_id = aws_cognito_user_pool.homeuniteus.id
}


### TODO: discuss secrets injection and Google integration with devops team
resource "aws_cognito_identity_provider" "google_client" {
  user_pool_id  = aws_cognito_user_pool.homeuniteus.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email profile openid"
    client_id        = data.aws_secretsmanager_secret_version.google_client_id.secret_string
    client_secret    = data.aws_secretsmanager_secret_version.google_secret.secret_string
    # attributes_url                = "https://people.googleapis.com/v1/people/me?personFields="
    # attributes_url_add_attributes = "true"
    # authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
    # oidc_issuer                   = "https://accounts.google.com"
    # token_request_method          = "POST"
    # token_url                     = "https://www.googleapis.com/oauth2/v4/token"
  }

  attribute_mapping = {
    birthdate    = "birthdays"
    email        = "email"
    family_name  = "family_name"
    gender       = "genders"
    given_name   = "given_name"
    name         = "names"
    phone_number = "phoneNumbers"
    picture      = "picture"
    username     = "sub"
  }
}

resource "aws_cognito_user_pool_client" "homeuniteus" {
  access_token_validity                = 30
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    "aws.cognito.signin.user.admin",
    "email",
    "openid",
    "phone",
    "profile"
  ]
  auth_session_validity = 3
  callback_urls = [
    "http://localhost:4040/signin",
    "http://localhost:4040/signup",
    "http://localhost:4040/signup/coordinator",
    "http://localhost:4040/signup/host",
    "https://dev.homeunite.us/signin",
    "https://dev.homeunite.us/signup",
    "https://dev.homeunite.us/signup/coordinator",
    "https://dev.homeunite.us/signup/host",
    "https://qa.homeunite.us/signin",
    "https://qa.homeunite.us/signup",
    "https://qa.homeunite.us/signup/coordinator",
    "https://qa.homeunite.us/signup/host"
  ]
  default_redirect_uri                          = null
  enable_propagate_additional_user_context_data = false
  enable_token_revocation                       = true
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
  generate_secret               = true
  id_token_validity             = 60
  logout_urls                   = []
  name                          = "homeuniteus"
  prevent_user_existence_errors = "ENABLED"
  read_attributes = [
    "address",
    "birthdate",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo"
  ]
  refresh_token_validity = 30
  ### TODO: Discuss with h4la ops team about client
  supported_identity_providers                  = [
    "COGNITO", 
    "Google"
  ]
  # supported_identity_providers = [
  #   "COGNITO"
  # ]
  user_pool_id = aws_cognito_user_pool.homeuniteus.id
  write_attributes = [
    "address",
    "birthdate",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo"
  ]
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

resource "aws_secretsmanager_secret" "cognito_client" {
  name = "homeuniteus-cognito-client"
}

resource "aws_secretsmanager_secret_version" "cognito_client" {
  secret_id     = aws_secretsmanager_secret.cognito_client.id
  secret_string = aws_cognito_user_pool_client.homeuniteus.client_secret
}

data "aws_iam_policy_document" "cognito_client" {
  statement {
    sid    = "EnableAnotherAWSAccountToReadTheSecret"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.appadmin.arn]
    }

    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

resource "aws_secretsmanager_secret_policy" "cognito_client" {
  secret_arn = aws_secretsmanager_secret.cognito_client.arn
  policy     = data.aws_iam_policy_document.cognito_client.json
}



data "aws_iam_policy_document" "admin_manage_secrets" {
  statement {
    sid    = "EnableAdminUserToManageTheSecret"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.appadmin.arn]
    }

    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:PutSecretValue"]
    resources = ["*"]
  }
}

resource "aws_secretsmanager_secret" "google_client_id" {
  name = "homeuniteus-google-clientid"
}

resource "aws_secretsmanager_secret_policy" "google_client_id" {
  secret_arn = aws_secretsmanager_secret.google_client_id.arn
  policy     = data.aws_iam_policy_document.admin_manage_secrets.json
}

data "aws_secretsmanager_secret_version" "google_client_id" {
  secret_id     = aws_secretsmanager_secret.google_client_id.id
}

resource "aws_secretsmanager_secret" "google_secret" {
  name = "homeuniteus-google-secret"
}

resource "aws_secretsmanager_secret_policy" "google_secret" {
  secret_arn = aws_secretsmanager_secret.google_secret.arn
  policy     = data.aws_iam_policy_document.admin_manage_secrets.json
}

data "aws_secretsmanager_secret_version" "google_secret" {
  secret_id     = aws_secretsmanager_secret.google_secret.id
}