# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../terraform-modules//ecs"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  env                    = local.environment_vars.locals.environment
  tags                   = local.environment_vars.locals.tags
  ecs_ec2_instance_count = local.environment_vars.locals.ecs_ec2_instance_count
  ecs_ec2_instance_type  = local.environment_vars.locals.ecs_ec2_instance_type
  key_name = local.environment_vars.locals.key_name

  aws_region     = local.account_vars.locals.aws_region
  aws_account_id = local.account_vars.locals.aws_account_id
  namespace      = local.account_vars.locals.namespace
  resource_name  = local.account_vars.locals.resource_name
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../network", "../alb"]
}
dependency "network" {
  config_path = "../network"
  // skip_outputs = true
  mock_outputs = {
  vpc_id            = "",
  vpc_cidr          = "",
  public_subnet_ids = [],
  }
}
dependency "alb" {
  config_path = "../alb"
  // skip_outputs = true
  mock_outputs = {
  security_group_id = "",
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  // Input from other Modules
  vpc_id                = dependency.network.outputs.vpc_id
  vpc_cidr              = dependency.network.outputs.vpc_cidr
  public_subnet_ids     = dependency.network.outputs.public_subnet_ids
  alb_security_group_id = dependency.alb.outputs.security_group_id

  // Input from Variables
  ecs_ec2_instance_count = local.ecs_ec2_instance_count
  ecs_ec2_instance_type  = local.ecs_ec2_instance_type
  key_name = local.key_name
  environment            = local.env
  resource_name          = local.resource_name
  tags                   = local.tags
}
