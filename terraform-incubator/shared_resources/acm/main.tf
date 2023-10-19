terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/acm/terraform.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

module "acm" {
  source = "../../../terraform-modules/acm"

  #domain_names = ["ballotnav.org", "civictechindex.org", "vrms.io", "homeunite.us"]
  domain_names = ["ballotnav.org", "civictechindex.org", "vrms.io"]
  tags         = { terraform_managed = "true", last_changed = formatdate("EEE YYYY-MMM-DD hh:mm:ss", timestamp()) }
}

output "acm_certificate_arns" {
  value = module.acm.acm_certificate_arns
}
