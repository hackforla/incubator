# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../terraform-modules//network"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  env           = local.environment_vars.locals.environment
  tags          = local.environment_vars.locals.tags
  aws_region    = local.account_vars.locals.aws_region
  namespace     = local.account_vars.locals.namespace
  resource_name = local.account_vars.locals.resource_name

}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  region    = local.aws_region
  namespace = local.namespace
  stage     = local.env
  name      = "${local.resource_name}-${local.env}"
  tags      = local.tags
}
