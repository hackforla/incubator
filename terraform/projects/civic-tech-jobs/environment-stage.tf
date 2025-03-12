
module "civic_tech_jobs_fullstack_stage_dns_entry" {
   source = "../../modules/dns-entry"
   subdomain = "stage"
   zone_id = "Z03052251DU06DMBYE89K"
}

module "civic_tech_jobs_stage_database" {
   source = "../../modules/database"
   project_name = local.project_name_civic_tech_jobs
   application_type = "fullstack"
   environment = "stage"
}

resource "random_password" "cookie_key" {
   length = 48
   special = false
}


module "civic_tech_jobs_backend_stage_service" {
   source = "../../modules/container"
   project_name = local.project_name_civic_tech_jobs
   environment = "stage"
   application_type = "fullstack"
   
   container_port = 8000
   container_image = "${module.civic_tech_jobs_ecr_fullstack.repository_url}:stage"
   container_environment = [
      { "name": "DEBUG", "value": "False"},
      { "name": "SECRET_KEY", "value": random_password.cookie_key.result},
      { "name": "DJANGO_PORT", "value": "8000"},
      { "name": "DJANGO_ALLOWED_HOSTS", "value": module.civic_tech_jobs_fullstack_stage_dns_entry.full_dns_name},
      { "name": "SECURE_HSTS_SECONDS", "value": "31536000"},
      { "name": "SECURE_HSTS_INCLUDE_SUBDOMAINS", "value": "True"},
      { "name": "SECURE_HSTS_PRELOAD", "value": "True"},
      { "name": "SESSION_COOKIE_SECURE", "value": "True"},
      { "name": "CSRF_COOKIE_SECURE", "value": "True"},
      { "name": "SQL_USER", "value": module.civic_tech_jobs_stage_database.owner_username},
      { "name": "SQL_DATABASE", "value": module.civic_tech_jobs_stage_database.database},
      { "name": "DATABASE", "value": module.civic_tech_jobs_stage_database.database},
      { "name": "SQL_ENGINE", "value": "django.db.backends.postgresql"},
      { "name": "SQL_HOST", "value": module.civic_tech_jobs_stage_database.host},
      { "name": "SQL_PORT", "value": module.civic_tech_jobs_stage_database.port},
      { "name": "COGNITO_DOMAIN", "value": "peopledepot"},
      { "name": "COGNITO_AWS_REGION", "value": "us-west-2"},
      { "name": "COGNITO_USER_POOL", "value": "us-west-2_Fn4rkZpuB"},
   ]
   container_environment_secrets = [
      { "name": "SQL_PASSWORD", "valueFrom": module.civic_tech_jobs_stage_database.owner_password_arn},
   ]
   
   hostname = module.civic_tech_jobs_fullstack_stage_dns_entry.full_dns_name
   path = "/*"

   listener_priority = 200
} 

