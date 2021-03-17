# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../terraform-modules//rds"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  rds_vars         = read_terragrunt_config(find_in_parent_folders("rds.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

  aws_region    = local.account_vars.locals.aws_region
  namespace     = local.account_vars.locals.namespace
  resource_name = local.account_vars.locals.resource_name

  create_db_instance = local.rds_vars.locals.create_db_instance
  db_username        = local.rds_vars.locals.db_username
  db_password        = local.rds_vars.locals.db_password
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
    vpc_id               = "",
    vpc_cidr             = "",
    private_subnet_ids   = [""],
    private_subnet_cidrs = [""]
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  resource_name = local.resource_name
  stage         = local.env
  region        = local.aws_region

  // Requires REPO_ROOT/incubator/rds.hcl
  create_db_instance = local.create_db_instance
  db_username        = local.db_username
  db_password        = local.db_password

  // Module Network variables
  vpc_id               = dependency.network.outputs.vpc_id
  vpc_cidr             = dependency.network.outputs.vpc_cidr
  private_subnet_ids   = dependency.network.outputs.private_subnet_ids
  private_subnet_cidrs = dependency.network.outputs.private_subnet_cidrs
}
