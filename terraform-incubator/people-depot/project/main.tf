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

module "people_depot" {
  source = "../../../terraform-modules/service"

  container_cpu   = 256
  aws_managed_dns = false
  container_env_vars = {
    SQL_HOST          = "incubator-prod-database.cewewwrvdqjn.us-west-2.rds.amazonaws.com"
    COGNITO_USER_POOL = "us-west-2_Fn4rkZpuB"

    COGNITO_AWS_REGION   = "us-west-2"
    DATABASE             = "postgres"
    DJANGO_ALLOWED_HOSTS = "localhost 127.0.0.1 [::1]"
    SECRET_KEY           = "foo"
    SQL_DATABASE         = "people_depot_dev"
    SQL_ENGINE           = "django.db.backends.postgresql"
    SQL_PASSWORD         = var.app_db_password
    SQL_PORT             = 5432
    SQL_USER             = "people_depot"
  }
  vpc_cidr          = "10.10.0.0/16"
  host_names        = ["people-depot-backend.com"]
  root_db_username  = "postgres"
  container_memory  = 512
  project_name      = "people-depot"
  postgres_database = {}
  region            = "us-west-2"
  health_check_path = "/"
  environment       = "dev"
  application_type  = "backend"
  launch_type       = "FARGATE"
  container_port    = 8000
  lambda_function   = "incubator-prod_multi-tenant-db"
  desired_count     = 1
  cluster_name      = "incubator-prod"
  path_patterns     = ["/*"]
  tags = {
    last_changed      = "Wed 2023-Jun-14 18:08:34"
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
