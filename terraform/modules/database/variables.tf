variable "shared_configuration" {
  description = "Configuration object from shared resources"
  type = object({
    alb_arn                 = string
    alb_https_listener_arn  = string
    cluster_id              = string
    cluster_name            = string
    task_execution_role_arn = string
    db_identifier           = string
    vpc_id                  = string
    public_subnet_ids       = set(string)
  })
}

variable "environment" {
  type = string
}

variable "db_name" {
  type = string
}

variable "owner_name" {
  type = string
}

variable "user_name" {
  type    = string
  default = ""
}

variable "viewer_name" {
  type    = string
  default = ""
}


output "host" {
  value = data.aws_db_instance.shared.address
}

output "port" {
  value = 5432
}

output "database" {
  value = postgresql_database.db.name
}

output "owner" {
  value = postgresql_role.db_owner.name
}

output "user" {
  value = length(postgresql_role.db_user) > 0 ? postgresql_role.db_user[0].name : "UNSET"
}

output "viewer" {
  value = length(postgresql_role.db_viewer) > 0 ? postgresql_role.db_viewer[0].name : "UNSET"
}

output "owner_password_arn" {
  value = aws_ssm_parameter.rds_dbowner_password.arn
}

output "user_password_arn" {
  value = aws_ssm_parameter.rds_dbuser_password.arn
}

output "viewer_password_arn" {
  value = aws_ssm_parameter.rds_dbviewer_password.arn
}
