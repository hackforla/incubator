terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/ecs/terraform.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
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
// XXX ew
data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/alb/terraform.tfstate"
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
}

module "ecs" {
  source = "../../../terraform-modules/ecs"

  vpc_id                = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr              = data.terraform_remote_state.network.outputs.vpc_cidr
  public_subnet_ids     = data.terraform_remote_state.network.outputs.public_subnet_ids
  alb_security_group_id = data.terraform_remote_state.alb.outputs.security_group_id

  // Input from Variables
  ecs_ec2_instance_count = local.ecs_ec2_instance_count
  ecs_ec2_instance_type  = local.ecs_ec2_instance_type
  key_name               = local.key_name
  environment            = local.env
  resource_name          = local.resource_name
  tags                   = local.tags
}
