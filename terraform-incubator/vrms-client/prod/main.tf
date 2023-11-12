terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/projects-prod/vrms-client/terraform.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

module "prod" {
  source = "../project"

  environment      = "prod"
  backend_host     = "localhost"
  client_url       = "https://vrms.io"
  react_app_proxy  = "https://vrms.io"
  host_names       = ["vrms.io"]

  root_db_password = var.root_db_password
  app_db_password  = var.app_db_password
  container_image  = "035866691871.dkr.ecr.us-west-2.amazonaws.com/vrms-client-prod:latest"
}