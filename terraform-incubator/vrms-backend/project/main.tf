data "terraform_remote_state" "shared" {
  backend = "s3"

  config = {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/./terraform.tfstate"
    region         = "us-west-2"
  }
}

module "vrms-backend" {
  source = "../../../terraform-modules/service"

  container_cpu   = 256
  aws_managed_dns = true
  container_env_vars = {
    BACKEND_PORT          = 4000
    CUSTOM_REQUEST_HEADER = "nAb3kY-S%qE#4!d"
    DATABASE_URL          = var.database_url
    GMAIL_CLIENT_ID       = var.gmail_client_id
    GMAIL_EMAIL           = "vrms.signup@gmail.com"
    GMAIL_REFRESH_TOKEN   = var.gmail_refresh_token
    GMAIL_SECRET_ID       = var.gmail_secret_id
    MAILHOG_PASSWORD      = var.mailhog_password
    MAILHOG_PORT          = 1025
    MAILHOG_USER          = "user"
    REACT_APP_PROXY       = "http://localhost:4000"
    SLACK_BOT_TOKEN       = var.slack_bot_token
    SLACK_CHANNEL_ID      = "D018H4TM94P"
    SLACK_CLIENT_ID       = var.slack_client_id
    SLACK_CLIENT_SECRET   = var.slack_client_secret
    SLACK_OAUTH_TOKEN     = var.slack_oauth_token
    SLACK_SIGNING_SECRET  = var.slack_signing_secret
    SLACK_TEAM_ID         = "T018WFQP5QD"
  }
  vpc_cidr          = "10.10.0.0/16"
  host_names        = var.host_names
  root_db_username  = "postgres" // this is required even though postgres_database controls whether or not it's even used
  root_db_password  = var.root_db_password
  lambda_function   = "incubator_multi-tenant-db"
  container_memory  = 512
  project_name      = "vrms"
  postgres_database = {}
  region            = "us-west-2"
  health_check_path = "/api/healthcheck"
  environment       = var.environment
  application_type  = "backend"
  launch_type       = "FARGATE"
  container_port    = 4000
  desired_count     = 1
  cluster_name      = "incubator-prod"
  path_patterns     = ["/api/*"]
  tags = {
    last_changed      = "Sat 2023-Nov-11 11:10:00"
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