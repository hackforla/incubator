# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../terraform-modules//r53"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  tags        = local.environment_vars.locals.tags
  domain_name = local.environment_vars.locals.domain_name
  host_names = local.environment_vars.locals.host_names
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../alb"]
}
dependency "alb" {
  config_path = "../alb"
  // skip_outputs = true
  mock_outputs = {
  lb_dns_name = ""
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  // Input from Variables
  domain_name = local.domain_name
  host_names = local.host_names
  tags = local.tags

  // Input from other Modules
  alb_external_dns = dependency.alb.outputs.lb_dns_name
}
