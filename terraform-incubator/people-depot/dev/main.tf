terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/projects-dev/people-depot-backend/terraform.tfstate"
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
}

moved {
  from = module.ecr.aws_ecr_repository.this
  to   = module.dev.module.people_depot.module.ecr.aws_ecr_repository.this
}
