locals {
  envname = "${var.application}-${var.environment}"
}

// --------------------------
// General/Global Variables
// --------------------------
variable "application" {
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
  description = "vpc private subnets cidrs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "vpc private subnet ids"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "vpc public subnets cidrs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "vpc public subnet ids"
  type        = list(string)
}

variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}

// --------------------------
// Database Variables
// --------------------------
variable "create_db_instance" {
  type    = bool
  default = false
}

variable "db_public_access" {
  description = "Bool to control if instance is publicly accessible"
  type        = bool
  default     = false
}

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
  default     = 5432
}

variable "db_instance_class" {
  description = "The instance type of the db"
  default     = "db.t3.small"
}
variable "db_engine_version" {
  description = "the database major and minor version of postgres"
  default     = "13.1"
}
variable "db_allow_major_engine_version_upgrade" {
  default = true
}

variable "db_major_version" {
  default = "13"
}


// --------------------------
// Migration Variables
// --------------------------
variable "db_snapshot_migration" {
  type        = string
  description = "Name of snapshot that will used to for new database, needs to in the same region"
  default     = ""
}
