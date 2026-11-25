variable "pghost" {
  type        = string
  description = "Endpoint of the shared RDS instance, incubator-prod-database. Not secret."
}

variable "pguser" {
  type        = string
  default     = "postgres"
  description = "Login the postgresql provider connects as. CI uses the default, the master user. Contributors running plan locally use terraform_plan, a login that can read but not change anything."
}

variable "pgpassword" {
  type        = string
  description = "Password for pguser. Also sets the RDS master password (password_wo in database.tf), but only when password_wo_version is bumped, so a plan with another login's password changes nothing."
}
