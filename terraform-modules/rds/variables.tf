locals {
  envname = "${var.resource_name}-${var.environment}"
}

// --------------------------
// General/Global Variables
// --------------------------
variable "resource_name" {
  type        = string
  description = "The overall name of the shared resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC cidr block"
}

variable "environment" {
  type        = string
  description = "a short name describing the lifecyle or stage of development that this is running for; ex: 'dev', 'qa', 'prod', 'test'"
}
variable "region" {
  type        = string
  description = "the aws region code where this is deployed; ex: 'us-west-2', 'us-east-1', 'us-east-2'"
}

variable "private_subnet_cidrs" {
  description = "private subnet cidrs from where to place the RDS instance"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "private subnet ids from where to place the RDS instance"
  type        = list(string)
}

variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}

// --------------------------
// Database Variables
// --------------------------
variable "db_username" {
  type        = string
  description = "The name of the default postgres user created by RDS when the instance is booted"
}

variable "db_password" {
  type        = string
  description = "The postgres database password created for the default database when the instance is booted"
}

variable "db_port" {
  type        = number
  description = "database port"
}

variable "db_instance_class" {
  description = "The instance type of the db; defaults to db.t2.small"
  default     = "db.t3.small"
}
variable "db_engine_version" {
  description = "the database major and minor version of postgres; default to 11.10"
  default     = "11.10"
}
variable "db_allow_major_engine_version_upgrade" {
  default = true
}

variable "db_major_version" {
  default = "11"
}


// --------------------------
// Migration Variables
// --------------------------
variable "db_snapshot_migration" {
  type        = string
  description = "Name of snapshot that will used to for new database, needs to in the same region"
  default     = ""
}
