# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
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
