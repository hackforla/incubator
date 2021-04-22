# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../terraform-modules//bastion"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  aws_region    = local.account_vars.locals.aws_region
  namespace     = local.account_vars.locals.namespace
  resource_name = local.account_vars.locals.resource_name

  key_name                 = local.account_vars.locals.key_name
  environment              = local.environment_vars.locals.environment
  tags                     = local.environment_vars.locals.tags
  bastion_hostname         = local.environment_vars.locals.bastion_hostname
  cron_key_update_schedule = local.environment_vars.locals.cron_key_update_schedule
  github_file              = local.environment_vars.locals.github_file

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
    vpc_id            = "",
    public_subnet_ids = [""]
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  // Input from other modules
  vpc_id            = dependency.network.outputs.vpc_id
  public_subnet_ids = dependency.network.outputs.public_subnet_ids

  // Input from variables
  region           = local.aws_region
  resource_name    = local.resource_name
  environment      = local.environment
  bastion_hostname = local.bastion_hostname

  keys_update_frequency = local.cron_key_update_schedule
  github_file           = local.github_file
  key_name              = local.key_name

  tags = local.tags
}
