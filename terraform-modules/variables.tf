// --------------------------
// Global/General Variables
// --------------------------
// variable "account_id" {
//   type        = string
//   description = "AWS Account ID"
// }

variable "region" {
  type = string
  default = "us-west-2"
}

variable "application" {
  type        = string
  description = "The overall name of the project using this infrastructure"
  default = "cpr"
}

variable "environment" {
  type = string
  default = "stage"
}

variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}

variable "domain_name" {
  type        = string
  description = "The domain name where the application will be deployed, must already live in AWS"
  default = "test.com"
}

variable "host_names" {
  description = "The URL where the application will be hosted, must be a subdomain of the domain_name"
  type        = list(string)
  default = []
}

variable "key_name" {
  type        = string
  description = "Pre-created SSH Key to use for ECS EC2 Instance"
  default = ""
}

variable "bastion_hostname" {
  type        = string
  description = "The hostname bastion, must be a subdomain of the domain_name"
  default = ""
}

variable "vpc_cidr" {
  type        = string
  default     = "10.10.0.0/16"
  description = "The range of IP addresses this vpc will reside in"
}

// --------------------------
// ALB Varialbes
// --------------------------
variable "default_alb_url" {
  type        = string
  description = "Default URL to forward the user if there is no ALB route rules that match"
  default = "www.maderenovation.com"
}

// --------------------------
// ECS/Fargat Variables
// --------------------------
variable "ecs_ec2_instance_count" {
  type    = number
  default = 1
}

// --------------------------
// RDS/Database Variables
// --------------------------
variable "create_db_instance" {
  type        = string
  description = "Flag to create DB Instace"
  default = "true"
}

variable "db_username" {
  type        = string
  description = "Databse Username"
}

variable "db_password" {
  type        = string
  description = "Databse Password"
}

variable "db_port" {
  type        = number
  description = "Databse Port, defaults to Postgres Port"
  default = 5432
}

variable "db_instance_class" {
  description = "The instance type of the db; defaults to db.t2.small"
  default     = "db.t3.small"
}

variable "db_engine_version" {
  description = "the database major and minor version of postgres; default to 11.10"
  default     = "12.5"
}

variable "db_major_version" {
  default = "12"
}

variable "db_snapshot_migration" {
  type        = string
  description = "Name of snapshot that will used to for new database, must be the same region as var.region"
  default     = ""
}

variable "db_public_access" {
  type = bool
  description = "enable database public access or not"
  default = true
}
// --------------------------
// Bastion Module Variables
// --------------------------
variable "bastion_instance_type" {
  description = "The ec2 instance type of the bastion server"
  default     = "t2.micro"
}

variable "bastion_github_file" {
  description = "the file located in Github for where the allowed github users will live"
  type        = map(any)
  default = {
    github_repo_owner = "codeforsanjose",
    github_repo_name  = "Infrastructure",
    github_branch     = "main",
    github_filepath   = "bastion_github_users",
  }
}
