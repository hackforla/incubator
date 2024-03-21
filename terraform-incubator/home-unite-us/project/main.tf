data "terraform_remote_state" "shared" {
  backend = "s3"

  # TODO: Ops: Identify obsolete config values - are we keeping the name statefile names with `terragrunt`?
  config = {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/./terraform.tfstate"
    region         = "us-west-2"
  }
}

locals {
  project_name     = "home-unite-us"
  project_dns_root = "homeunite.us"
}

module "home_unite_us" {
  source = "../../../terraform-modules/service"

  container_cpu   = 256
  aws_managed_dns = false
  container_env_vars = {
    SQL_HOST = "incubator-prod-database.cewewwrvdqjn.us-west-2.rds.amazonaws.com"

    # TODO: Ops: find the correct value for this
    COGNITO_USER_POOL = "us-west-2_Fn4rkZpuB"

    COGNITO_AWS_REGION   = "us-west-2"
    DATABASE             = "postgres"
    DJANGO_ALLOWED_HOSTS = "localhost 127.0.0.1 [::1]"
    SECRET_KEY           = "foo"
    SQL_DATABASE         = replace(local.project_name, "-", "_")
    SQL_ENGINE           = "django.db.backends.postgresql"
    SQL_PASSWORD         = var.app_db_password
    SQL_PORT             = 5432
    SQL_USER             = "home_unite_us"
  }
  # TODO: Ops: Get a valid available IP range 
  vpc_cidr         = "10.10.0.0/16"
  host_names       = var.environment == "prod" ? ["${local.project_dns_root}"] : ["${var.environment}.${local.project_dns_root}"]
  root_db_username = "postgres"

  # TODO: HUU: is this enough memory?
  container_memory  = 512
  project_name      = local.project_name
  postgres_database = {}
  region            = "us-west-2"
  health_check_path = "/"
  environment       = var.environment
  application_type  = "backend"
  launch_type       = "FARGATE"
  container_port    = 8000
  lambda_function   = "incubator-prod_multi-tenant-db"
  desired_count     = 1
  cluster_name      = "incubator-prod"
  path_patterns     = ["/*"]
  tags = {
    # last_changed      = "Wed 2023-Jun-14 18:08:34"
    # TODO: Ops: Confirm DD over just D for this date string
    last_changed      = formatdate("EEE YYYY-MMM-DD hh:mm:ss", timestamp())
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

  root_db_password = var.root_db_password
}

variable "root_db_password" {
  type        = string
  description = "root database password"
}

variable "app_db_password" {
  type = string
}

variable "container_image" {
  type = string
}


variable "environment" {
  type    = string
  default = "dev"
}
