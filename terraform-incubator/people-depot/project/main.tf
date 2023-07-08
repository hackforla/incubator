variable "root_db_password" {
  type        = string
  description = "root database password"
}

variable "app_db_password" {
  type = string
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


  # problematic
  #  alb_external_dns        = "incubator-prod-lb-569274394.us-west-2.elb.amazonaws.com"
  #  cluster_id              = "arn:aws:ecs:us-west-2:035866691871:cluster/incubator-prod"
  #  task_execution_role_arn = "arn:aws:iam::035866691871:role/incubator-prod-ecs-task-role"
  #  alb_security_group_id   = "sg-07dd18f4255a5a5aa"
  #  container_image         = "035866691871.dkr.ecr.us-west-2.amazonaws.com/people-depot-backend-dev:latest"
  #  alb_https_listener_arn  = "arn:aws:elasticloadbalancing:us-west-2:035866691871:listener/app/incubator-prod-lb/7451adf77133ef36/390a225766a4daf3"
  #  db_instance_endpoint    = "incubator-prod-database.cewewwrvdqjn.us-west-2.rds.amazonaws.com:5432"
  #  vpc_id                  = "vpc-0bec93a4d80243845"
  #  public_subnet_ids       = ["subnet-03202f3bf9a24c1a5", "subnet-08c26edd1afc2b9d7"]
  #
  root_db_password = var.root_db_password
}
