variable "project_name" {
  type = string
  description = "HfLA project name (vrms, home-unite-us, etc)"
}

variable "application_type" {
  type = string
  description = "frontend, backend, or fullstack"
}

variable "environment" {
  type = string
  description = "what environment this is for - staging, production, etc"
}




output "host" {
  value = data.aws_db_instance.shared.address
  description = "hostname URL of RDS postgresql database"
}

output "port" {
  value = 5432
  description = "running port of RDS postgresql database"
}

output "database" {
  value = postgresql_database.db.name
  description = "name of created postgresql database"
}

output "owner_username" {
  value = postgresql_role.db_owner.name
  description = "login username of 'owner' user"
}

output "user_username" {
  value = postgresql_role.db_owner.name
  description = "login username of 'user' user"
}

output "viewer_username" {
  value = postgresql_role.db_owner.name
  description = "login username of 'viewer' user"
}

output "owner_password_arn" {
  value = module.db_owner_password.arn
  description = "SSM parameter ARN of password for 'owner' user"
}

output "user_password_arn" {
  value = module.db_user_password.arn
  description = "SSM parameter ARN of password for 'user' user"
}

output "viewer_password_arn" {
  value = module.db_viewer_password.arn
  description = "SSM parameter ARN of password for 'viewer' user"
}

output "owner_password" {
  value = module.db_owner_password.value
  sensitive = true
  description = "'owner' user password credential"
}

output "user_password" {
  value = module.db_user_password.value
  sensitive = true
  description = "'user' user password credential"
}

output "viewer_password" {
  value = module.db_viewer_password.value
  sensitive = true
  description = "'viewer' user password credential"
}
