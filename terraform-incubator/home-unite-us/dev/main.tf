resource "aws_route53_zone" "main" {
  name = "homeunite.us"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "homeunite.us"
  type    = "A"
  ttl     = 300
  records = ["18.223.160.58"]
}

terraform {

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    region   = "us-west-2"
    key      = "incubator/home-unite-us/dev.tfstate"
    bucket   = "hlfa-incubator-terragrunt"
  }
}

provider "aws" {
  region = "us-west-2"
}
