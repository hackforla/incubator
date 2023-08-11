terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/network/terraform.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
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

module "network" {
  source = "../../../terraform-modules/network"

  region        = local.aws_region
  resource_name = local.resource_name
  environment   = local.env
  tags          = local.tags
}
