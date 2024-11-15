data "terraform_remote_state" "shared" {
  backend = "s3"

  config = {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/./terraform.tfstate"
    region         = "us-west-1"
  }
}

module "vrms-client" {
  source = "../../../terraform-modules/service"

  project_name       = "vrms"
  application_type   = "client"
  environment        = var.environment
  region             = "us-west-2"
  desired_count      = 1
  container_cpu      = 256
  container_memory   = 512
  container_port     = 3000
  container_env_vars = {
    BACKEND_HOST                    = var.backend_host
    BACKEND_PORT                    = 4000
    CLIENT_PORT                     = 443
    CLIENT_URL                      = var.client_url
    REACT_APP_CUSTOM_REQUEST_HEADER = "nAb3kY-S%qE#4!d"
    REACT_APP_PROXY                 = var.react_app_proxy
    }
  aws_managed_dns    = false 
  vpc_cidr           = "10.10.0.0/16"
  host_names         = var.host_names
  path_patterns      = ["/*"]
  postgres_database  = {}
  root_db_username   = "username" // not actually used
  root_db_password   = var.root_db_password // not actually used
  health_check_path  = "/healthcheck"
  launch_type        = "FARGATE"
  lambda_function    = "lambda"
  cluster_name       = "incubator-prod"
  tags = {
    last_changed      = "Wed 2024-Feb-28 20:02:00"
    terraform_managed = "true"
  }

  container_image = var.container_image

  alb_external_dns        = data.terraform_remote_state.shared.outputs.alb_external_dns
  cluster_id              = data.terraform_remote_state.shared.outputs.cluster_id
  task_execution_role_arn = data.terraform_remote_state.shared.outputs.task_execution_role_arn
  alb_security_group_id   = data.terraform_remote_state.shared.outputs.alb_security_group_id
  alb_https_listener_arn  = data.terraform_remote_state.shared.outputs.alb_https_listener_arn
  db_instance_endpoint    = data.terraform_remote_state.shared.outputs.db_instance_endpoint
  vpc_id                  = data.terraform_remote_state.shared.outputs.vpc_id
  public_subnet_ids       = data.terraform_remote_state.shared.outputs.public_subnet_ids
}