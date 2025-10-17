
module "qa_dns_entry" {
   source = "../../modules/dns-entry"
   subdomain = "qa1"
   zone_id = "Z03829196Z0VAL9Q8CZ"
}

module "database_dev" {
   source = "../../modules/database"
   project_name = local.project_name
   application_type = "fullstack"
   environment = "qa"
}

module "db_url_qa" {
    source = "../../modules/secret"
    project_name = local.project_name
    application_type = "fullstack"
    environment = "qa"
    value = "postgresql+psycopg2://${module.database_dev.owner_username}:${module.database_dev.owner_password}@${module.database_dev.host}:${module.database_dev.port}/${module.database_dev.database}"
    name = "database_url"
}


module "qa_service" {
   source = "../../modules/container"
   project_name = local.project_name
   environment = "qa"
   application_type = "fullstack"

   launch_type = "ec2"
   
   container_port = 80
   container_image = "${module.ecr_fullstack.repository_url}:qa"
   container_environment = [
      { "name": "APP_ENVIRONMENT", "value": "dev"},
      { "name": "COGNITO_CLIENT_ID", "value": aws_cognito_user_pool_client.homeuniteus.id},
      { "name": "COGNITO_CLIENT_SECRET", "value": aws_cognito_user_pool_client.homeuniteus.client_secret},
      { "name": "COGNITO_REGION", "value": "us-west-2"},
      { "name": "COGNITO_REDIRECT_URI", "value": "https://${module.qa_dns_entry.full_dns_name}/signin"},
      { "name": "COGNITO_USER_POOL_ID", "value": aws_cognito_user_pool.homeuniteus.id},
      { "name": "COGNITO_ENDPOINT_URL", "value": "https://home-unite-us.auth.us-west-2.amazoncognito.com"},
      { "name": "COGNITO_ACCESS_ID", "value": ""},
      { "name": "COGNITO_ACCESS_KEY", "value": ""},
      { "name": "HUU_ENVIRONMENT", "value": "dev"},
      { "name": "ROOT_URL", "value": "https://${module.qa_dns_entry.full_dns_name}"},
      { "name": "LOG_LEVEL", "value": "INFO"}
   ]
   container_environment_secrets = [
      { "name": "DATABASE_URL", "valueFrom": module.db_url_qa.arn},
   ]
   
   hostname = module.qa_dns_entry.full_dns_name
   path = "/*"

   listener_priority = 300
} 


resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = module.qa_service.task_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}
