
module "stage_database_username_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "stage-database-username"
   value = " "
}


module "stage_database_password_secret" {
   source = "../../modules/secret"
   application_type = "backend"
   project_name = local.project_name
   name = "stage-database-password"
   value = " "
}



module "backend_stage_service" {
   source = "../../modules/container"
   project_name = "cti"
   environment = "stage"
   application_type = "backend"
   
   launch_type = "ec2"
   
   container_port = 8000
   container_image = "${module.ecr_backend_stage.repository_url}:77845e0"
   container_environment = [
      { "name": "POSTGRES_DATABASE", "value": "cti_stage"},
      { "name": "POSTGRES_HOST", "value": "incubator-prod-database.cewewwrvdqjn.us-west-2.rds.amazonaws.com"},
      { "name": "POSTGRES_PORT", "value": "5432"},
   ]
   container_environment_secrets = [
      { "name": "POSTGRES_USER", "valueFrom": module.stage_database_username_secret.arn},
      { "name": "POSTGRES_PASSWORD", "valueFrom": module.stage_database_password_secret.arn},
   ]
   
   // stage.api.civictechindex.org was the hostname until hackforla/incubator#183. It
   // never worked over HTTPS: the certificate on the listener is *.civictechindex.org,
   // a single-label wildcard that does not cover a three-label name, so TLS failed
   // before any request was made. api-stage is the same service by a spelling the
   // certificate covers. The DNS record for stage.api was deleted at the same time.
   hostname = "api-stage.civictechindex.org"
   path = "/*"
   health_check_path = "/status/"

   listener_priority = 500
} 