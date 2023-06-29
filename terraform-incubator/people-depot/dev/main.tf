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

module "dev" {
  source = "../project"

  root_db_password = var.root_db_password
}
