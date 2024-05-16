terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/projects-dev/civic-tech-jobs-api/terraform.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

module "dev" {
  source = "../project"
  container_image  = "035866691871.dkr.ecr.us-west-2.amazonaws.com/civic-tech-jobs-dev:latest"
}