terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/projects-dev/vrms-client/terraform.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

module "dev" {
  source = "../project"

  environment      = "dev"
  backend_host     = "https://dev.vrms.io"
  client_url       = "https://dev.vrms.io"
  react_app_proxy  = "https://dev.vrms.io"
  host_names       = ["dev.vrms.io"]

  root_db_password = var.root_db_password
  app_db_password  = var.app_db_password
  container_image  = "035866691871.dkr.ecr.us-west-2.amazonaws.com/vrms-client-dev:latest"
}