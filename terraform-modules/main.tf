terraform {
  required_version = "~>0.14.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    key            = "terraform-state/cpr/stage/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
  }
}

module "network" {
  source = "./network"

  // Input from Variables
  vpc_cidr    = "10.0.0.0/16"
  region      = var.region
  application = var.application
  environment = var.environment
  tags        = var.tags
}

module "alb" {
  source = "./applicationlb"

  // Input from other Modules
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  // Input from Variables
  region              = var.region
  environment         = var.environment
  application         = var.application
  default_alb_url     = var.default_alb_url
  acm_certificate_arn = "arn:aws:acm:us-west-2:035866691871:certificate/34571e39-da2b-42de-bd9c-02b38e6b30b4"

  tags = var.tags
}

module "ecs" {
  source = "./ecs"

  // Input from other Modules
  vpc_id            = module.network.vpc_id
  vpc_cidr            = module.network.vpc_cidr
  public_subnet_ids = module.network.public_subnet_ids
  alb_security_group_id = module.alb.security_group_id

  // Input from Variables
  environment         = var.environment
  application         = var.application
  ecs_ec2_instance_count = 1
  ecs_ec2_instance_type = "t3.large"
  key_name = var.key_name

  tags = var.tags
}

module "ecr" {
  source = "./ecr"

  application = var.application
  environment = var.environment
  repos       = ["backend", "frontend"]
}

module "rds" {
  source = "./rds"

  application = var.application
  environment = var.environment
  region        = var.region

  create_db_instance    = var.create_db_instance
  db_public_access      = var.db_public_access
  db_snapshot_migration = var.db_snapshot_migration
  db_username           = var.db_username
  db_password           = var.db_password

  // Module Network variables
  vpc_id               = module.network.vpc_id
  vpc_cidr             = module.network.vpc_cidr
  public_subnet_ids    = module.network.public_subnet_ids
  public_subnet_cidrs  = module.network.public_subnet_cidrs
  private_subnet_ids   = module.network.public_subnet_ids
  private_subnet_cidrs = module.network.public_subnet_cidrs
}
