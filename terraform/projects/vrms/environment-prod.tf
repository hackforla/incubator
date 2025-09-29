# module "prod_dns_entry" {
#    source = "../../modules/dns-entry"
#    subdomain = "www"
#    zone_id = "Z0420800PGQ9JP6DM9EX"
# }

# module "prod_root_dns_entry" {
#    source = "../../modules/dns-entry"
#    subdomain = "www"
#    zone_id = "Z0420800PGQ9JP6DM9EX"
# }

module "prod_database_url_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "prod-database-url"
   value = " "
}


module "backend_prod_service" {
   source = "../../modules/container"
   project_name = local.project_name
   environment = "prod"
   application_type = "backend"
   
   launch_type = "ec2"
   
   container_port = 4000
   container_image = "${module.ecr_backend.repository_url}:prod"
   container_environment = [
      { "name": "BACKEND_PORT", "value": "4000"},
      { "name": "GMAIL_EMAIL", "value": "vrms.signup@gmail.com"},
      { "name": "MAILHOG_PORT", "value": "1025"},
      { "name": "REACT_APP_PROXY", "value": "http://localhost:4000"},
      { "name": "SLACK_CHANNEL_ID", "value": "D018H4TM94P"},
      { "name": "SLACK_CLIENT_ID", "value": "1302534787829.1327799404688"},
      { "name": "SLACK_TEAM_ID", "value": "T018WFQP5QD"}
   ]
   container_environment_secrets = [
      { "name": "CUSTOM_REQUEST_HEADER", "valueFrom": module.custom_request_header_secret.arn},
      { "name": "DATABASE_URL", "valueFrom": module.prod_database_url_secret.arn},
      { "name": "GMAIL_CLIENT_ID", "valueFrom": module.gmail_client_id_secret.arn},
      { "name": "GMAIL_REFRESH_TOKEN", "valueFrom": module.gmail_refresh_token_secret.arn},
      { "name": "GMAIL_SECRET_ID", "valueFrom": module.gmail_secret_id_secret.arn},
      { "name": "MAILHOG_PASSWORD", "valueFrom": module.mailhog_password_secret.arn},
      { "name": "MAILHOG_USER", "valueFrom": module.mailhog_user_secret.arn},
      { "name": "SLACK_BOT_TOKEN", "valueFrom": module.slack_bot_token_secret.arn},
      { "name": "SLACK_CLIENT_SECRET", "valueFrom": module.slack_client_secret_secret.arn},
      { "name": "SLACK_OAUTH_TOKEN", "valueFrom": module.slack_oauth_token_secret.arn},
      { "name": "SLACK_SIGNING_SECRET", "valueFrom": module.slack_signing_secret_secret.arn}
   ]
   
   hostname = "vrms.io"
   additional_host_urls = ["www.vrms.io"]
   path = "/api/*"
   health_check_path = "/api/healthcheck"

   listener_priority = 402
} 


module "frontend_prod_service" {
   source = "../../modules/container"
   project_name = local.project_name
   environment = "prod"
   application_type = "frontend"

   launch_type = "ec2"
   
   container_port = 3000
   container_image = "${module.ecr_frontend.repository_url}:prod"
   container_environment = [
      { "name": "BACKEND_HOST", "value": "https://vrms.io"},
      { "name": "BACKEND_PORT", "value": "4000"},
      { "name": "CLIENT_PORT", "value": "443"},
      { "name": "CLIENT_URL", "value": "https://vrms.io"},
      { "name": "REACT_APP_PROXY", "value": "https://vrms.io"}
   ]
   container_environment_secrets = [
      { "name": "REACT_APP_CUSTOM_REQUEST_HEADER", "valueFrom": module.custom_request_header_secret.arn}
   ]
   
   hostname = "vrms.io"
   additional_host_urls = ["www.vrms.io"]

   path = "/*"

   listener_priority = 403
} 
