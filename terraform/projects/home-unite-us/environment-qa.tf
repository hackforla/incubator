
module "qa_dns_entry" {
   source = "../../modules/dns-entry"
   subdomain = "qa1"
   zone_id = "Z0420800PGQ9JP6DM9EX"
}

module "database_dev" {
   source = "../../modules/database"
   project_name = local.project_name
   application_type = "fullstack"
   environment = "qa"
}


module "qa_service" {
   source = "../../modules/container"
   project_name = local.project_name
   environment = "qa"
   application_type = "fullstack"
   
   container_port = 80
   container_image = "${module.ecr_fullstack.repository_url}:qa"
   container_environment = [
      { "name": "APP_ENVIRONMENT", "value": "dev"}
   ]
   container_environment_secrets = [
   ]
   
   hostname = module.qa_dns_entry.full_dns_name
   path = "/*"

   listener_priority = 200
} 