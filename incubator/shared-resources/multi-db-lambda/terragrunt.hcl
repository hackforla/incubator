# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../terraform-modules//multi-tenant-database"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  rds_vars         = read_terragrunt_config(find_in_parent_folders("rds.hcl"))


  # Extract out common variables for reuse
  tags = local.environment_vars.locals.tags
  env  = local.environment_vars.locals.environment

  aws_region    = local.account_vars.locals.aws_region
  namespace     = local.account_vars.locals.namespace
  resource_name = local.account_vars.locals.resource_name

  create_db_instance = local.rds_vars.locals.create_db_instance
  db_public_access   = local.rds_vars.locals.db_public_access
  db_username        = local.rds_vars.locals.db_username
  db_password        = local.rds_vars.locals.db_password
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../network", "../rds"]
}
dependency "network" {
  config_path = "../network"
  // skip_outputs = true
  mock_outputs = {
    vpc_id               = "",
    vpc_cidr             = "10.0.0.0/16",
    public_subnet_ids    = [""],
    public_subnet_cidrs  = [""],
    private_subnet_ids   = [""],
    private_subnet_cidrs = [""]
  }
}
dependency "rds" {
  config_path = "../rds"
  // skip_outputs = true
  mock_outputs = {
    db_instance_endpoint = "",
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  resource_name = local.resource_name
  stage         = local.env
  region        = local.aws_region
  tags          = local.tags

  // Requires REPO_ROOT/incubator/rds.hcl
  create_db_instance = local.create_db_instance
  db_public_access   = local.db_public_access
  db_username        = local.db_username
  db_password        = local.db_password

  // Module Network variables
  vpc_id               = dependency.network.outputs.vpc_id
  vpc_cidr             = dependency.network.outputs.vpc_cidr
  public_subnet_ids    = dependency.network.outputs.public_subnet_ids
  public_subnet_cidrs  = dependency.network.outputs.public_subnet_cidrs
  private_subnet_ids   = dependency.network.outputs.public_subnet_ids
  private_subnet_cidrs = dependency.network.outputs.public_subnet_cidrs

  // Contains hostname and port
  db_endpoint = dependency.rds.outputs.db_instance_endpoint
}
