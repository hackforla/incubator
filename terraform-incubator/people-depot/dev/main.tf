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
  default     = "password"
}

variable "app_db_password" {
  type = string
  default     = "password"
}

module "dev" {
  source = "../project"

  root_db_password = var.root_db_password
  app_db_password  = var.app_db_password
  container_image  = "035866691871.dkr.ecr.us-west-2.amazonaws.com/people-depot-backend-dev:latest"
}

module "cognito" {
  source = "../../../terraform-modules/cognito"

  region         = "us-west-2"
  user_pool_name = "people-depot-user-pool"
  client_name    = "people-depot-client"
}
moved {
  from = module.ecr.aws_ecr_repository.this
  to   = module.dev.module.people_depot.module.ecr.aws_ecr_repository.this
}
