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

// Create an Apex DNS record that aliases to the LB
data "aws_lb" "lb" {
  arn = local.shared_configuration.alb_arn
}
resource "aws_route53_record" "apex" {
  zone_id = local.zone_id
  name    = aws_route53_zone.this.name
  type    = "A"

  alias {
    name                   = data.aws_lb.lb.dns_name
    zone_id                = data.aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}
