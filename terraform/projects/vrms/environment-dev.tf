module "dev_dns_entry" {
   source = "../../modules/dns-entry"
   subdomain = "dev2"
   zone_id = "Z0420800PGQ9JP6DM9EX"
}

module "dev_database_url_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "dev-database-url"
   value = " "
}



module "backend_dev_service" {
   source = "../../modules/container"
   project_name = local.project_name
   environment = "dev2"
   application_type = "backend"
   
   container_port = 4000
   container_image = "${module.ecr_backend.repository_url}:dev"
   container_environment = [
      { "name": "BACKEND_PORT", "value": "4000"}
   ]
   container_environment_secrets = [
      { "name": "CUSTOM_REQUEST_HEADER", "valueFrom": module.custom_request_header_secret.arn},
      { "name": "DATABASE_URL", "valueFrom": module.dev_database_url_secret.arn},
   ]
   
   hostname = module.dev_dns_entry.full_dns_name
   path = "/api/*"

   listener_priority = 400
} 
