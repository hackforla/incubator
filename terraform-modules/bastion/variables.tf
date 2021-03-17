locals {
  envname = "${var.resource_name}-${var.environment}"
}

// --------------------------
// Global/General Variables
// --------------------------
variable "account_id" {
  description = "AWS Account ID"
}

variable "resource_name" {
  type        = string
  description = "The overall name of the shared resources"
}

variable "environment" {
  type = string
}

variable "domain_name" {
  type        = string
  description = "The domain name where the application will be deployed, must already live in AWS"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}

// --------------------------
// Bastion Instance Variables
// --------------------------
variable "bastion_hostname" {
  type        = string
  description = "The hostname bastion, must be a subdomain of the domain_name"
}

variable "bastion_instance_type" {
  description = "The ec2 instance type of the bastion server"
  default     = "t2.micro"
}

variable "public_subnet_ids" {
  description = "public subnet ids for where to place bastion"
  type        = list(string)
}

variable "key_name" {
  description = "SSH key to be added as the default AMI user"
  type        = string
  default     = ""
}

// --------------------------
// user_data.sh Variables
// --------------------------
variable "ssh_user" {
  default = "ubuntu"
}

variable "bastion_github_file" {
  type = map(string)
  default = {
    github_repo_owner = "codeforsanjose",
    github_repo_name  = "Infrastructure",
    github_branch     = "main",
    github_filepath   = "bastion_github_users",
  }
}

variable "enable_hourly_cron_updates" {
  default = "false"
}

variable "cron_key_update_schedule" {
  default     = "5,0,*,* * * * *"
  description = "The cron schedule that public keys are synced from the bastion s3 bucket to the server; default to once every hour"
}

variable "additional_user_data_script" {
  default = ""
}