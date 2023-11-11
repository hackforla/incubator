terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/projects-prod/vrms-backend/terraform.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

module "prod" {
  source = "../project"

  environment      = "prod"
  root_db_password = "password" // not really needed because we don't use a postgres database in this project
  container_image  = "035866691871.dkr.ecr.us-west-2.amazonaws.com/vrms-backend-dev:latest"
  host_names       = ["vrms.io"]
  database_url     = "mongodb+srv://admin:admin123@cluster0-haogu.mongodb.net/db?retryWrites=true&w=majority"

  # These are input locally through a .tfvars file
  gmail_client_id = var.gmail_client_id
  gmail_refresh_token = var.gmail_refresh_token
  gmail_secret_id = var.gmail_secret_id
  mailhog_password = var.mailhog_password
  slack_bot_token = var.slack_bot_token
  slack_client_id = var.slack_client_id
  slack_client_secret = var.slack_client_secret
  slack_oauth_token = var.slack_oauth_token
  slack_signing_secret = var.slack_signing_secret
}