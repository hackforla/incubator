terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    region = "us-west-2"
    key    = "incubator/home-unite-us/dev.tfstate"
    bucket = "hlfa-incubator-terragrunt"
  }
}
