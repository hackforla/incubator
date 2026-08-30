// Production Cognito for home-unite-us, adopted in place rather than rebuilt.
//
// `Home Unite Us` (us-west-2_VH24AGQ3p) is the production pool. It holds the real
// user accounts, and its pool id and client id are baked into the running production
// container image, so it is imported as-is. The `home-unite-us` pool in cognito-qa.tf
// is a separate pool used only by qa1.homeunite.us. Both are real and neither
// replaces the other -- see hackforla/incubator#166.
//
// Every value below is written to match live AWS exactly, so that `terraform plan`
// after the imports in ../../import.tf reports no changes at all. A proposed change
// here is a defect in this file, not drift to be accepted.

resource "aws_iam_role" "cognito_idp_prod" {
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

// The inline policy name matches the role name, which is NOT the same convention as
// the QA role in cognito-qa.tf (there both are "home-unite-us-cognito-idp"). Renaming
// it would destroy and recreate the policy, so it stays as the live name.
resource "aws_iam_role_policy" "cognito_sns_prod" {
  name = "homeuniteus-cognito-idp"
  role = aws_iam_role.cognito_idp_prod.id

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

resource "aws_cognito_user_pool" "homeuniteus_prod" {
  name = "Home Unite Us"

  // The pool predates Cognito's tier feature and is on LITE. The provider defaults
  // this attribute to ESSENTIALS, so omitting it would plan a billing upgrade on the
  // live production pool. Do not remove this line.
  user_pool_tier = "LITE"

  mfa_configuration        = "OPTIONAL"
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

  // Points at the legacy customMessage/mergeUsers pair by literal ARN. Those two
  // functions are not managed by Terraform. This is deliberate: re-pointing the pool
  // at the already-managed home-unite-us-* pair is a live change to production
  // sign-up, and folding it in here would stop this import from planning clean.
  // Tracked as follow-on work -- see hackforla/incubator#166.
  lambda_config {
    custom_message = "arn:aws:lambda:us-west-2:035866691871:function:customMessage"
    pre_sign_up    = "arn:aws:lambda:us-west-2:035866691871:function:mergeUsers"
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
    sns_caller_arn = aws_iam_role.cognito_idp_prod.arn
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

  // Destroying this pool destroys the production user accounts, which cannot be
  // recovered by recreating it. deletion_protection above is the AWS-side guard;
  // this is the Terraform-side one.
  lifecycle {
    prevent_destroy = true
  }
}

// Listed explicitly rather than reusing local.groups from cognito-qa.tf. The two
// pools happen to carry the same four groups today, but sharing the list would mean
// an edit made for QA silently changes group membership on the production pool.
resource "aws_cognito_user_group" "homeuniteus_prod" {
  for_each = toset([
    "Hosts",
    "Guests",
    "Coordinators",
    "Admins"
  ])
  name         = each.value
  user_pool_id = aws_cognito_user_pool.homeuniteus_prod.id
  description  = "Managed by Terraform"
}

resource "aws_cognito_user_pool_domain" "homeuniteus_prod" {
  domain       = "homeuniteus"
  user_pool_id = aws_cognito_user_pool.homeuniteus_prod.id
}

// Reads the same two secrets as the QA provider in cognito-qa.tf. The legacy
// homeuniteus-google-clientid and homeuniteus-google-secret hold byte-identical
// values (verified by digest, 2026-08-30), so both pools use the same Google OAuth
// client and the legacy copies are redundant rather than separate credentials.
resource "aws_cognito_identity_provider" "google_client_prod" {
  user_pool_id = aws_cognito_user_pool.homeuniteus_prod.id

  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes              = "email profile openid"
    client_id                     = data.aws_secretsmanager_secret_version.google_client_id.secret_string
    client_secret                 = data.aws_secretsmanager_secret_version.google_secret.secret_string
    attributes_url                = "https://people.googleapis.com/v1/people/me?personFields="
    attributes_url_add_attributes = "true"
    authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
    oidc_issuer                   = "https://accounts.google.com"
    token_request_method          = "POST"
    token_url                     = "https://www.googleapis.com/oauth2/v4/token"
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

// The client id here is compiled into the production frontend bundle, so this
// resource must not be replaced. Note the callback URLs cover localhost, dev and qa
// but not www -- the production image's ROOT_URL is https://qa.homeunite.us, which is
// why the production listener rule serves that hostname. Adding www is a separate
// change that needs a frontend rebuild to be useful.
resource "aws_cognito_user_pool_client" "homeuniteus_prod" {
  name         = "homeuniteus"
  user_pool_id = aws_cognito_user_pool.homeuniteus_prod.id

  access_token_validity                = 30
  id_token_validity                    = 60
  refresh_token_validity               = 30
  auth_session_validity                = 3
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    "aws.cognito.signin.user.admin",
    "email",
    "openid",
    "phone",
    "profile"
  ]

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
  logout_urls                                   = []
  enable_propagate_additional_user_context_data = false
  enable_token_revocation                       = true
  generate_secret                               = true
  prevent_user_existence_errors                 = "ENABLED"

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  supported_identity_providers = [
    "COGNITO",
    "Google"
  ]

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

  // generate_secret cannot be read back from the API, so on import Terraform sees it
  // going from null to true and plans a replacement. Replacing this client would mint
  // a new client id, which is compiled into the production frontend bundle and would
  // break sign-in. prevent_destroy is deliberate belt-and-braces: if some future
  // change does require replacement, the plan should fail loudly rather than proceed.
  lifecycle {
    ignore_changes  = [generate_secret]
    prevent_destroy = true
  }
}

// Only the secret container is managed, not its version. The stored value is the
// production client secret that the running container authenticates with, and
// importing the version risks Terraform rewriting it. Anything in this repo that
// needs the value should read aws_cognito_user_pool_client.homeuniteus_prod
// .client_secret directly rather than this secret.
resource "aws_secretsmanager_secret" "cognito_client_prod" {
  name = "homeuniteus-cognito-client"
}
