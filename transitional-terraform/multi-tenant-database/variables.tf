locals {
  db_subnet_ids = var.db_public_access ? var.public_subnet_ids : var.private_subnet_ids
  envname       = "${var.resource_name}-${var.environment}"
}

variable "resource_name" {
  type        = string
  description = "The overall name of the shared resources"
}

variable "environment" {
  type        = string
  description = "a short name describing the lifecyle or stage of development that this is running for; ex: 'dev', 'qa', 'prod', 'test'"
}

variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC cidr block"
}

variable "private_subnet_ids" {
  description = "vpc private subnet ids"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "vpc public subnet ids"
  type        = list(string)
}

variable "db_public_access" {
  description = "Bool to control if instance is publicly accessible"
  type        = bool
  default     = false
}

variable "create_db_instance" {
  type    = bool
  default = false
}
