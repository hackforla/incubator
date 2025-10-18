/**
 * # database
 *
 * Creates a database on a shared RDS posgresql instance. The name of the 
 * created database has the format `project-name_application-type_environment`.
 * For example, for the production backend database of vrms, the created
 * database name will be `vrms_backend_production`.
 *
 * This module also creates three users:
 * 1. viewer - read access
 * 1. user - read/write access
 * 1. owner - admin access
 *
 * The credentials get stored as secrets (SSM parameters). The ARNs of those
 * parameters are output variables, listed below
 */

// terraform-docs-ignore
data "aws_db_instance" "shared" {
  db_instance_identifier = "incubator-prod-database"
}




/*
* Generated Passwords
*/

module "db_owner_password" {
  source = "../secret"
  application_type = var.application_type
  project_name = var.project_name
  environment = var.environment
  length = 48
  name = "db-owner-password"
}


module "db_user_password" {
  source = "../secret"
  application_type = var.application_type
  project_name = var.project_name
  environment = var.environment
  length = 48
  name = "db-user-password"
}


module "db_viewer_password" {
  source = "../secret"
  application_type = var.application_type
  project_name = var.project_name
  environment = var.environment
  length = 48
  name = "db-viewer-password"
}


/*
*  Postgres Roles
*/
resource "postgresql_role" "db_owner" {
  name     = "${var.project_name}_${var.application_type}_${var.environment}_owner"
  login    = true
  password = module.db_owner_password.value
}

resource "postgresql_role" "db_user" {
  name     = "${var.project_name}_${var.application_type}_${var.environment}_user"
  login    = true
  password = module.db_user_password.value
}

resource "postgresql_role" "db_viewer" {
  name     = "${var.project_name}_${var.application_type}_${var.environment}_viewer"
  login    = true
  password = module.db_viewer_password.value
}


/*
* Usernames stored as secrets
*/ 

module "db_owner_username" {
  source = "../secret"
  application_type = var.application_type
  project_name = var.project_name
  environment = var.environment
  value = postgresql_role.db_owner.name
  name = "db-owner-username"
}


module "db_user_username" {
  source = "../secret"
  application_type = var.application_type
  project_name = var.project_name
  environment = var.environment
  value = postgresql_role.db_user.name
  name = "db-user-username"
}


module "db_viewer_username" {
  source = "../secret"
  application_type = var.application_type
  project_name = var.project_name
  environment = var.environment
  value = postgresql_role.db_viewer.name
  name = "db-viewer-username"
}


/*
*  Postgres Grants - apply permissions to generated roles
*/

resource "postgresql_grant" "user" {
  database    = postgresql_database.db.name
  role        = postgresql_role.db_user.name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_grant" "viewer" {
  database    = postgresql_database.db.name
  role        = postgresql_role.db_viewer.name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT"]
}


/*
* Postgres DB, using generated owner
*/

resource "postgresql_database" "db" {
  name  = "${var.project_name}_${var.application_type}_${var.environment}"
  owner = postgresql_role.db_owner.name
}