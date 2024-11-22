locals {
  envname = "${var.resource_name}-${var.environment}"
}

variable "region" {
  type = string
}

variable "resource_name" {
  type        = string
  description = "The overall name of the shared resources"
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  default = "10.10.0.0/16"
  type    = string
}

variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}
