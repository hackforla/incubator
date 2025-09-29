
module "prod_database_username_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "prod-database-username"
   value = " "
}


module "prod_database_password_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "prod-database-password"
   value = " "
}



module "backend_prod_service" {
   source = "../../modules/container"
   project_name = "cti"
   environment = "prod"
   application_type = "backend"
   
   launch_type = "ec2"
   
   container_port = 8000
   container_image = "035866691871.dkr.ecr.us-west-2.amazonaws.com/civictechindex-backend-prod:77845e0"
   container_environment = [
      { "name": "POSTGRES_DATABASE", "value": "cti_prod"},
      { "name": "POSTGRES_HOST", "value": "incubator-prod-database.cewewwrvdqjn.us-west-2.rds.amazonaws.com"},
      { "name": "POSTGRES_PORT", "value": "5432"},
   ]
   container_environment_secrets = [
      { "name": "POSTGRES_USER", "valueFrom": module.prod_database_username_secret.arn},
      { "name": "POSTGRES_PASSWORD", "valueFrom": module.prod_database_password_secret.arn},
   ]
   
   hostname = "api.civictechindex.org"
   path = "/*"
   health_check_path = "/status/"

   listener_priority = 501
} 