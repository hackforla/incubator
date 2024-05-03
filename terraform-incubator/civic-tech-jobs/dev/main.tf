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
  container_image  = "035866691871.dkr.ecr.us-west-2.amazonaws.com/ctj-backend-dev:latest"
}

moved {
  from = module.ecr.aws_ecr_repository.this
  to   = module.dev.module.people_depot.module.ecr.aws_ecr_repository.this
}
