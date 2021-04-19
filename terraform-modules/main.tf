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
    bucket         = "codeforcalifornia"
    key            = "terraform-state/cpr/stage/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-locks"
  }
}

module "network" {
  source = "./network"

  // Input from Variables
  region    = var.region
  resource_name = var.project_name
  stage     = var.environment
  name      = "${var.project_name}-${var.environment}"
  tags      = var.tags
}
