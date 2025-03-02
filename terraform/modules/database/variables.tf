variable "project_name" {
  type = string
}

variable "application_type" {
  type = string
}

variable "environment" {
  type = string
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

output "owner_username" {
  value = postgresql_role.db_owner.name
}

output "user_username" {
  value = postgresql_role.db_owner.name
}

output "viewer_username" {
  value = postgresql_role.db_owner.name
}

output "owner_password_arn" {
  value = module.db_owner_password.arn
}

output "user_password_arn" {
  value = module.db_user_password.arn
}

output "viewer_password_arn" {
  value = module.db_viewer_password.arn
}

output "owner_password" {
  value = module.db_owner_password.value
  sensitive = true
}

output "user_password" {
  value = module.db_user_password.value
  sensitive = true
}

output "viewer_password" {
  value = module.db_viewer_password.value
  sensitive = true
}
