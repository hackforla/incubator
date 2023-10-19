terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/rds/terraform.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_ssm_parameter" "rds_credentials" {
  name = "rds_credentials"
}

// XXX ew
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/network/terraform.tfstate"
    region         = "us-west-2"
  }
}

locals {
  account_vars = {
    aws_region    = "us-west-2"
    namespace     = "hfla"
    resource_name = "incubator"
  }

  aws_region    = local.account_vars.aws_region
  resource_name = local.account_vars.resource_name
  env           = "prod"
  tags          = { terraform_managed = "true", last_changed = formatdate("EEE YYYY-MMM-DD hh:mm:ss", timestamp()) }

  db_public_access      = true
  db_snapshot_migration = ""
  db_username           = "postgres"
  db_password           = data.aws_ssm_parameter.rds_credentials.value
}

module "rds" {
  source = "../../../terraform-modules/rds"

  resource_name = local.resource_name
  environment   = local.env
  region        = local.aws_region

  create_db_instance    = true
  db_public_access      = local.db_public_access
  db_snapshot_migration = local.db_snapshot_migration
  db_username           = local.db_username
  db_password           = local.db_password

  vpc_id               = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr             = data.terraform_remote_state.network.outputs.vpc_cidr
  public_subnet_ids    = data.terraform_remote_state.network.outputs.public_subnet_ids
  public_subnet_cidrs  = data.terraform_remote_state.network.outputs.public_subnet_cidrs
  private_subnet_ids   = data.terraform_remote_state.network.outputs.public_subnet_ids
  private_subnet_cidrs = data.terraform_remote_state.network.outputs.public_subnet_cidrs
}

output "db_identifier" {
  value = module.rds.db_identifier
}

output "db_address" {
  value = module.rds.db_address
}

output "db_instance_hosted_zone_id" {
  value = module.rds.db_instance_hosted_zone_id
}

output "db_instance_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_security_group_id" {
  value = module.rds.db_security_group_id
}
