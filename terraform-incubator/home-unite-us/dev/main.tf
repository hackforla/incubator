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

locals {
  host_name = "homeunite.us"
  app_name = "homeuniteus"
  listener_arn = "arn:aws:elasticloadbalancing:us-west-2:035866691871:listener/app/incubator-prod-lb/7451adf77133ef36/390a225766a4daf3"
}

resource "aws_route53_zone" "main" {
  name = local.host_name
}

resource "aws_route53_record" "root_a_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.host_name
  type    = "A"
  ttl     = 300
  records = ["18.223.160.58"]
}

resource "aws_ecr_repository" "this" {
    image_tag_mutability = "MUTABLE"
    name                 = local.app_name
    tags                 = {
      "Organization" = "Hack for LA"
    }

    image_scanning_configuration {
        scan_on_push = true
    }
}

data "aws_lb_listener" "listener" {
  arn = local.listener_arn
}