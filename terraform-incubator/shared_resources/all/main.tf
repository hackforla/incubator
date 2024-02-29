terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/./terraform.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}


data "terraform_remote_state" "shared" {
  for_each = toset(["network", "ecs", "rds", "alb", "multi-db-lambda"])
  backend  = "s3"

  config = {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/${each.key}/terraform.tfstate"
    region         = "us-west-2"
  }
}

locals {
  configuration = {
    alb_arn = data.terraform_remote_state.shared["alb"].outputs.lb_arn
    # XXX Prefer using the ARN to set up a data.aws_lb and get values from there
    alb_external_dns       = data.terraform_remote_state.shared["alb"].outputs.lb_dns_name
    alb_zone_id            = data.terraform_remote_state.shared["alb"].outputs.lb_zone_id
    alb_security_group_id  = data.terraform_remote_state.shared["alb"].outputs.security_group_id
    alb_https_listener_arn = data.terraform_remote_state.shared["alb"].outputs.alb_https_listener_arn

    cluster_id = data.terraform_remote_state.shared["ecs"].outputs.cluster_id
    # XXX Prefer using the cluster_id to set up a data.aws_ecs and get values from there
    cluster_name            = data.terraform_remote_state.shared["ecs"].outputs.cluster_name
    task_execution_role_arn = data.terraform_remote_state.shared["ecs"].outputs.task_execution_role_arn

    db_identifier = data.terraform_remote_state.shared["rds"].outputs.db_identifier
    # XXX Prefer using the identifier to set up a data.aws_db_instance
    db_instance_endpoint = data.terraform_remote_state.shared["rds"].outputs.db_instance_endpoint

    vpc_id            = data.terraform_remote_state.shared["network"].outputs.vpc_id
    public_subnet_ids = data.terraform_remote_state.shared["network"].outputs.public_subnet_ids
  }
}

# XXX individual outputs are not preferred -
# instead use the configuration output
output "alb_arn" {
  value = local.configuration.alb_arn
}
output "alb_external_dns" {
  value = local.configuration.alb_external_dns
}
output "alb_zone_id" {
  value = local.configuration.alb_zone_id
}
output "alb_security_group_id" {
  value = local.configuration.alb_security_group_id
}
output "alb_https_listener_arn" {
  value = local.configuration.alb_https_listener_arn
}
output "cluster_id" {
  value = local.configuration.cluster_id
}
output "cluster_name" {
  value = local.configuration.cluster_name
}
output "task_execution_role_arn" {
  value = local.configuration.task_execution_role_arn
}
output "db_identifier" {
  value = local.configuration.db_identifier
}
output "db_instance_endpoint" {
  value = local.configuration.db_instance_endpoint
}
output "vpc_id" {
  value = local.configuration.vpc_id
}
output "public_subnet_ids" {
  value = local.configuration.public_subnet_ids
}

#value = data.terraform_remote_state.shared["network"].outputs.vpc_cidr
#value = data.terraform_remote_state.shared["multi-db"].outputs.lambda_function
#value = data.terraform_remote_state.shared["ecs"].outputs.cluster_name

output "configuration" {
  value = local.configuration
}
