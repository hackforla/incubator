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
  container_env_vars = {
    DJANGO_ALLOWED_HOSTS = "localhost 127.0.0.1 [::1]"
  }
  tags = {
    last_changed      = "Wed 2023-Jun-14 18:08:34"
    terraform_managed = "true"
  }

  container_image = var.container_image
}

variable "container_image" {
  type = string
}
