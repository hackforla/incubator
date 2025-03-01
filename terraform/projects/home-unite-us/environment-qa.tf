
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