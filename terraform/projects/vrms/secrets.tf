
module "custom_request_header_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "custom-request-header"
   value = ""
}

module "gmail_client_id_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "gmail-client-id"
   value = ""
}

module "gmail_refresh_token_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "gmail-refresh-token"
   value = ""
}

module "gmail_secret_id_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "gmail-secret-id"
   value = ""
}

module "mailhog_password_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "mailhog-password"
   value = ""
}

module "mailhog_user_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "mailhog-user"
   value = ""
}

module "slack_bot_token_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "slack-bot-token"
   value = ""
}

module "slack_client_secret_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "slack-client-secret"
   value = ""
}

module "slack_oauth_token_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "slack-oauth-token"
   value = ""
}

module "slack_signing_secret_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "slack-signing-secret"
   value = ""
}