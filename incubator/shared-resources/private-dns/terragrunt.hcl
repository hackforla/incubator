# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../terraform-modules//private-dns"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  aws_region     = local.account_vars.locals.aws_region
  aws_account_id = local.account_vars.locals.aws_account_id
  namespace      = local.account_vars.locals.namespace
  resource_name  = local.account_vars.locals.resource_name

  env  = local.environment_vars.locals.environment
  tags = local.environment_vars.locals.tags
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../network"]
}
dependency "network" {
  config_path = "../network"
  // skip_outputs = true
  mock_outputs = {
  vpc_id = "",
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  // Input from other Modules
  vpc_id = dependency.network.outputs.vpc_id

  // Input from Variables
  account_id    = local.aws_account_id
  region        = local.aws_region
  environment   = local.env
  resource_name = local.resource_name
  tags          = local.tags
}
