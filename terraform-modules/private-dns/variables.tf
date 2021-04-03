locals {
  envname = "${var.resource_name}-${var.environment}"
}
// --------------------------
// Global/General Variables
// --------------------------
variable "resource_name" {
  description = "The overall name of the project using this infrastructure; used to group related resources by"
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}