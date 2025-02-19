
module "people_depot_backend_stage_dns_entry" {
   source = "../../modules/dns-entry"
   subdomain = "peopledepot-dev"
   zone_id = "Z0420800PGQ9JP6DM9EX"
}

module "people_depot_dev_database" {
   source = "../../modules/database"
   project_name = local.project_name_people_depot
   application_type = "backend"
   environment = "dev"
}

resource "random_password" "cookie_key" {
   length = 48
   special = false
}

module "people_depot_backend_dev_api_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name_people_depot
   environment = "dev"
   name = "api-secret"
}

module "people_depot_backend_stage_service" {
   source = "../../modules/container"
   project_name = local.project_name_people_depot
   environment = "dev"
   application_type = "backend"
   
   container_port = 8000
   container_image = "${module.people_depot_ecr_backend.repository_url}:dev"
   container_environment = [
      { "name": "DEBUG", "value": "false"},
      { "name": "SECRET_KEY", "value": random_password.cookie_key.result},
      { "name": "DJANGO_PORT", "value": "8000"},
      { "name": "DJANGO_ALLOWED_HOSTS", "value": module.people_depot_backend_stage_dns_entry.full_dns_name},
      { "name": "SECURE_HSTS", "value": "31536000"},
      { "name": "SECURE_HSTS_INCLUDE_SUBDOMAINS", "value": "true"},
      { "name": "SECURE_HSTS_PRELOAD", "value": "true"},
      { "name": "SECURE_SSL_REDIRECT", "value": "true"},
      { "name": "SESSION_COOKIE_SECURE", "value": "true"},
      { "name": "CSRF_COOKIE_SECURE", "value": "true"},
      { "name": "SQL_USER", "value": module.people_depot_dev_database.owner_username},
      { "name": "SQL_DATABASE", "value": module.people_depot_dev_database.database},
      { "name": "DATABASE", "value": module.people_depot_dev_database.database},
      { "name": "SQL_ENGINE", "value": "django.db.backends.postgresql"},
      { "name": "SQL_HOST", "value": module.people_depot_dev_database.host},
      { "name": "SQL_PORT", "value": module.people_depot_dev_database.port},
      { "name": "COGNITO_DOMAIN", "value": "peopledepot"},
      { "name": "COGNITO_AWS_REGION", "value": "us-west-2"},
      { "name": "COGNITO_USER_POOL", "value": "us-west-2_Fn4rkZpuB"},
   ]
   container_environment_secrets = [
      { "name": "SQL_PASSWORD", "valueFrom": module.people_depot_dev_database.owner_password_arn},
      { "name": "PEOPLE_DEPOT_API_SECRET", "valueFrom": module.people_depot_backend_dev_api_secret.arn},
   ]
   
   hostname = module.people_depot_backend_stage_dns_entry.full_dns_name
   path = "/*"

   listener_priority = 100
} 

