terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/projects-dev/vrms-backend/terraform.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

module "dev" {
  source = "../project"

  environment      = "dev"
  root_db_password = "password" // not really needed because we don't use a postgres database in this project
  container_image  = "035866691871.dkr.ecr.us-west-2.amazonaws.com/vrms-backend-dev:latest"
  host_names       = ["dev.vrms.io"]
  database_url     = "mongodb+srv://editor:557Ith3jq7ap2mnO@cluster0.5buwz.mongodb.net/vrms-test?retryWrites=true&w=majority"
}