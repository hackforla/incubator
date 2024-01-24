// Get configuration from the shared infrastructure
data "terraform_remote_state" "shared" {
  backend = "s3"

  config = {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/./terraform.tfstate"
    region         = "us-west-2"
  }
}

locals {
  shared_configuration = data.terraform_remote_state.shared.outputs.configuration
}

provider "aws" {
  region = "us-west-2"
}

// Set up Postgres provider to create the database
terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.21.0"
    }
  }
}
data "aws_ssm_parameter" "rds_credentials" {
  name = "rds_credentials"
}
data "aws_db_instance" "shared" {
  db_instance_identifier = local.shared_configuration.db_identifier
}
provider "postgresql" {
  host      = data.aws_db_instance.shared.address
  password  = data.aws_ssm_parameter.rds_credentials.value
  username  = "postgres"
  superuser = false
}
