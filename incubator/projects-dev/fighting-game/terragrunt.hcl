# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../terraform-modules//service-client"
}

locals {
  # Automatically load environment-level variables
  project_vars     = read_terragrunt_config("project.hcl")
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  tags = local.environment_vars.locals.tags

  // Container
  env = local.project_vars.locals.environment
  application_type = local.project_vars.locals.application_type
  launch_type = local.project_vars.locals.launch_type
  container_image  = local.project_vars.locals.container_image
  desired_count    = local.project_vars.locals.desired_count
  container_port   = local.project_vars.locals.container_port
  container_cpu    = local.project_vars.locals.container_cpu
  container_memory = local.project_vars.locals.container_memory
  container_env_vars = local.project_vars.locals.container_env_vars
  health_check_path = local.project_vars.locals.health_check_path

  project_name = local.project_vars.locals.project_name
  host_names    = local.project_vars.locals.host_names

  aws_region     = local.account_vars.locals.aws_region
  aws_account_id = local.account_vars.locals.aws_account_id
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../../shared-resources/network", "../../shared-resources/alb", "../../shared-resources/ecs"]
}
dependency "network" {
  config_path = "../../shared-resources/network"
  // skip_outputs = true
  mock_outputs = {
  vpc_id            = "",
  vpc_cidr = "",
  public_subnet_ids = [],
  }
}
dependency "alb" {
  config_path = "../../shared-resources/alb"
  // skip_outputs = true
  mock_outputs = {
  security_group_id      = "",
  alb_target_group_arn   = "",
  alb_https_listener_arn = "",
  }
}
dependency "ecs" {
  config_path = "../../shared-resources/ecs"
  // skip_outputs = true
  mock_outputs = {
  cluster_name      = "",
  cluster_id        = "",
  task_execution_role_arn = ""
  }
}


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  // Input from other Modules
  vpc_id                 = dependency.network.outputs.vpc_id
  vpc_cidr                 = dependency.network.outputs.vpc_cidr
  public_subnet_ids      = dependency.network.outputs.public_subnet_ids
  alb_https_listener_arn = dependency.alb.outputs.alb_https_listener_arn
  alb_security_group_id = dependency.alb.outputs.security_group_id
  cluster_name           = dependency.ecs.outputs.cluster_name
  cluster_id             = dependency.ecs.outputs.cluster_id
  task_execution_role_arn = dependency.ecs.outputs.task_execution_role_arn

  // Input from Variables
  account_id   = local.aws_account_id
  region       = local.aws_region
  tags = local.tags

  environment  = local.env
  project_name = local.project_name
  host_names    = local.host_names

  // Container Variables
  application_type = local.application_type
  launch_type = local.launch_type
  container_image  = local.container_image
  desired_count    = local.desired_count
  container_port   = local.container_port
  container_memory = local.container_memory
  container_cpu    = local.container_cpu
  container_env_vars = local.container_env_vars
  health_check_path = local.health_check_path
}
