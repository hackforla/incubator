# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../terraform-modules//cicd_integration"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  
  account_id = local.account_vars.locals.aws_account_id
  tags = local.environment_vars.locals.tags
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../ecs"]
}
dependency "ecs" {
  config_path = "../ecs"
  // skip_outputs = true
  mock_outputs = {
  task_execution_role_arn = ""
  }
}

inputs = {
  account_id = local.account_id
  tags = local.tags

  execution_role_arn = dependency.ecs.outputs.task_execution_role_arn
}
