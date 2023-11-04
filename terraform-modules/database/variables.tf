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

variable "username" {
  type = string
}

output "host" {
  value = data.aws_db_instance.shared.address
}

output "port" {
  value = 5432
}

output "database" {
  value = postgresql_database.db[0].name
}

output "user" {
  value = postgresql_role.db_owner[0].name
}

output "password_arn" {
  value = aws_ssm_parameter.rds_dbowner_password.arn
}
