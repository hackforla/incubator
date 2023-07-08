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


locals {
  # Automatically load environment-level variables
  #environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment_vars = {
    environment = "prod"

    // ALB
    default_alb_url = "www.hackforla.org"

    // Amazon Certificate Manager
    // Hardcoding pre-created certificate to avoid reaching limit https://github.com/aws/aws-cdk/issues/5889
    // domain_names = ["ballotnav.org", "civictechindex.org", "vrms.io", "homeunite.us"]
    domain_names = ["ballotnav.org", "civictechindex.org", "vrms.io"] // , "homeunite.us"]

    // Route 53 Records - That will point to the ALB
    // host_names = ["fight.foodoasis.net"]
    host_names = []

    // ECS
    ecs_ec2_instance_count = 0
    ecs_ec2_instance_type  = "t3.small"

    // Bastion
    bastion_hostname         = "bastion-incubator.hackforla.org"
    cron_key_update_schedule = "5,0,*,* * * * *"
    github_file = {
      github_repo_owner = "hackforla",
      github_repo_name  = "incubator",
      github_branch     = "main",
      github_filepath   = "bastion_github_users",
    }

    // Global tags
    tags = { terraform_managed = "true", last_changed = formatdate("EEE YYYY-MMM-DD hh:mm:ss", timestamp()) }
  }

  # account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_vars = {
    aws_region    = "us-west-2"
    namespace     = "hfla"
    resource_name = "incubator"

    # Pre-created AWS Resources:
    # S3 Bucket for storing Terragrunt/Terraform State files
    s3_terragrunt_region = "us-west-2"
    s3_terragrunt_bucket = "hlfa-incubator-terragrunt"
    # DynamoDB Table for storing lock files to avoid collision
    dynamodb_terraform_lock = "terraform-locks"
    # EC2 SSH Key
    key_name = "hfla-incubator-us-west-2" #TODO: Make optional
  }

  rds_vars = {
    db_username        = "postgres"
    create_db_instance = true
    db_public_access   = true

    // Create Database from pre-existing snapshot
    // https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Tutorials.RestoringFromSnapshot.html
    // Defaults to empty string, meaning create fresh database
    db_snapshot_migration = ""
  }

  # Extract out common variables for reuse
  env           = local.environment_vars.environment
  tags          = local.environment_vars.tags
  aws_region    = local.account_vars.aws_region
  namespace     = local.account_vars.namespace
  resource_name = local.account_vars.resource_name

  s3_terragrunt_region    = local.account_vars.s3_terragrunt_region
  s3_terragrunt_bucket    = local.account_vars.s3_terragrunt_bucket
  dynamodb_terraform_lock = local.account_vars.dynamodb_terraform_lock


  create_db_instance    = local.rds_vars.create_db_instance
  db_public_access      = local.rds_vars.db_public_access
  db_snapshot_migration = local.rds_vars.db_snapshot_migration
  db_username           = local.rds_vars.db_username
}

variable "db_password" {
  type = string
}

module "network" {
  source = "../../terraform-modules/network"

  region        = local.aws_region
  resource_name = local.resource_name
  environment   = local.env
  tags          = local.tags
}

module "rds" {
  source = "../../terraform-modules/rds"

  region        = local.aws_region
  resource_name = local.resource_name
  environment   = local.env
  tags          = local.tags

  db_username = local.db_username
  db_password = var.db_password

  vpc_id               = module.network.vpc_id
  vpc_cidr             = module.network.vpc_cidr
  public_subnet_ids    = module.network.public_subnet_ids
  public_subnet_cidrs  = module.network.public_subnet_cidrs
  private_subnet_ids   = module.network.public_subnet_ids
  private_subnet_cidrs = module.network.public_subnet_cidrs
}

module "multi-db" {
  source = "../../terraform-modules/multi-tenant-database"

  resource_name = local.resource_name
  environment   = local.env
  tags          = local.tags

  vpc_id             = module.network.vpc_id
  vpc_cidr           = module.network.vpc_cidr
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.public_subnet_ids

  create_db_instance = local.create_db_instance
  db_public_access   = local.db_public_access
}

module "alb" {
  source = "../../terraform-modules/applicationlb"

  region        = local.aws_region
  resource_name = local.resource_name
  environment   = local.env
  tags          = local.tags

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  acm_certificate_arns = module.acm.acm_certificate_arns
  default_alb_url      = local.environment_vars.default_alb_url
}

module "acm" {
  source = "../../terraform-modules/acm"

  domain_names = local.environment_vars.domain_names
  tags         = local.tags
}

module "ecs" {
  source = "../../terraform-modules/ecs"

  resource_name = local.resource_name
  environment   = local.env
  tags          = local.tags

  vpc_id            = module.network.vpc_id
  vpc_cidr          = module.network.vpc_cidr
  public_subnet_ids = module.network.public_subnet_ids

  alb_security_group_id  = module.alb.security_group_id
  ecs_ec2_instance_count = local.environment_vars.ecs_ec2_instance_count
  ecs_ec2_instance_type  = local.environment_vars.ecs_ec2_instance_type
  key_name               = local.account_vars.key_name
}
