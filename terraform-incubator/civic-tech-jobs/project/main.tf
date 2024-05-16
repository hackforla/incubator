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

module "civic-tech-jobs" {
  source = "../../../terraform-modules/service"
  aws_managed_dns = false
  container_env_vars = {
    DJANGO_ALLOWED_HOSTS = "localhost 127.0.0.1 [::1]"
  }
  container_memory  = 512
  project_name      = "civic-tech-jobs"
  region            = "us-west-2"
  health_check_path = "/health_check"
  environment       = "dev"
  application_type  = "backend"
  tags = {
    last_changed      = "Wed 2023-Jun-14 18:08:34"
    terraform_managed = "true"
  }

  container_image = var.container_image
}

variable "container_image" {
  type = string
}
