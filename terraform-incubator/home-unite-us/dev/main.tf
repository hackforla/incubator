terraform {
  # TODO: Ops: Identify obsolete config values - are we keeping the name statefile names with `terragrunt`?
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    # TODO: Ops: Identify obsolete config values - are we keeping the name statefile names with `terragrunt`?
    key            = "terragrunt-states/incubator/projects-dev/home-unite-us/terraform.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

variable "root_db_password" {
  type        = string
  description = "root database password"
}

variable "app_db_password" {
  type = string
}

module "dev" {
  source = "../project"

  root_db_password = var.root_db_password
  app_db_password  = var.app_db_password
  container_image  = "<TODO>"
}