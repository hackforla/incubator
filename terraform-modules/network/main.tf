data "aws_caller_identity" "current" {}
locals {
  tags = merge(var.tags, { terraform_user_arn = data.aws_caller_identity.current.arn })
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.envname}-vpc"

  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 8, 3), cidrsubnet(var.vpc_cidr, 8, 4)]

  enable_dns_hostnames = true
  enable_ipv6          = false

  enable_nat_gateway = false
  single_nat_gateway = false

  tags = local.tags

  vpc_tags = merge({ Name = "${local.envname}-vpc" }, local.tags)
}
