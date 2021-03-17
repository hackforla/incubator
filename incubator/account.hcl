# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "DarrentPham"
  aws_account_id = "470363915259"
  aws_region     = "us-west-1"
  namespace      = "hfla"
  resource_name  = "incubator"
}