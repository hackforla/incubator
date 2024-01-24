terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/alb/terraform.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

data "terraform_remote_state" "shared" {
  for_each = toset(["network", "acm"])
  backend  = "s3"

  config = {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/${each.key}/terraform.tfstate"
    region         = "us-west-2"
  }
}

module "alb" {
  source = "../../../terraform-modules/applicationlb"

  vpc_id               = data.terraform_remote_state.shared["network"].outputs.vpc_id
  public_subnet_ids    = data.terraform_remote_state.shared["network"].outputs.public_subnet_ids
  acm_certificate_arns = data.terraform_remote_state.shared["acm"].outputs.acm_certificate_arns

  // Input from Variables
  environment     = "prod"
  region          = "us-west-2"
  resource_name   = "incubator"
  default_alb_url = "www.hackforla.org"

  tags = { terraform_managed = "true", last_changed = formatdate("EEE YYYY-MMM-DD hh:mm:ss", timestamp()) }
}

output "alb_id" {
  value = module.alb.alb_id
}

output "security_group_id" {
  value = module.alb.security_group_id
}

output "lb_dns_name" {
  value = module.alb.lb_dns_name
}

output "lb_zone_id" {
  value = module.alb.lb_zone_id
}

output "lb_arn" {
  value = module.alb.lb_arn
}

output "alb_target_group_arn" {
  value = module.alb.alb_target_group_arn
}

output "alb_target_group_id" {
  value = module.alb.alb_target_group_arn
}

output "alb_https_listener_arn" {
  value = module.alb.alb_https_listener_arn
}
