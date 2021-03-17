# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../terraform-modules//applicationlb"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  default_alb_url  = local.environment_vars.locals.default_alb_url
  env  = local.environment_vars.locals.environment
  tags = local.environment_vars.locals.tags

  aws_region     = local.account_vars.locals.aws_region
  aws_account_id = local.account_vars.locals.aws_account_id
  resource_name  = local.account_vars.locals.resource_name
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../network", "../acm"]
}
dependency "network" {
  config_path = "../network"
  // skip_outputs = true
  mock_outputs = {
  vpc_id            = "",
  public_subnet_ids = ""
  }
}
dependency "acm" {
  config_path = "../acm"
  // skip_outputs = true
  mock_outputs = {
  acm_certificate_arn = ""
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  // Input from other Modules
  vpc_id              = dependency.network.outputs.vpc_id
  public_subnet_ids   = dependency.network.outputs.public_subnet_ids
  acm_certificate_arn = dependency.acm.outputs.acm_certificate_arn

  // Input from Variables
  account_id    = local.aws_account_id
  region        = local.aws_region
  environment   = local.env
  resource_name = local.resource_name
  default_alb_url = local.default_alb_url

  tags = local.tags
}