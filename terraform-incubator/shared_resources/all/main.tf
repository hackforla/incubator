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

output "alb_external_dns" {
  value = data.terraform_remote_state.shared["alb"].outputs.lb_dns_name
}
output "alb_security_group_id" {
  value = data.terraform_remote_state.shared["alb"].outputs.security_group_id
}
output "alb_https_listener_arn" {
  value = data.terraform_remote_state.shared["alb"].outputs.alb_https_listener_arn
}
output "cluster_id" {
  value = data.terraform_remote_state.shared["ecs"].outputs.cluster_id
}
output "task_execution_role_arn" {
  value = data.terraform_remote_state.shared["ecs"].outputs.task_execution_role_arn
}
output "db_address" {
  value = data.terraform_remote_state.shared["rds"].outputs.db_address
}
output "db_instance_endpoint" {
  value = data.terraform_remote_state.shared["rds"].outputs.db_instance_endpoint
}
output "vpc_id" {
  value = data.terraform_remote_state.shared["network"].outputs.vpc_id
}
output "public_subnet_ids" {
  value = data.terraform_remote_state.shared["network"].outputs.public_subnet_ids
}

#value = data.terraform_remote_state.shared["network"].outputs.vpc_cidr
#value = data.terraform_remote_state.shared["multi-db"].outputs.lambda_function
#value = data.terraform_remote_state.shared["ecs"].outputs.cluster_name
