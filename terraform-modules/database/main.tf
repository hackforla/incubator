terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.21.0"
    }
  }
}

data "aws_secretsmanager_random_password" "db_password_init" {
  password_length     = 48
  exclude_punctuation = true
}

data "aws_db_instance" "shared" {
  db_instance_identifier = var.shared_configuration.db_identifier
}

// We're using the random_password data source to initialize this;
// we use the lifecycle.ignore_changes to say that we don't want
// the value to be updated. We get most of the benefit of a
// Secret Manager entry, and save 0.40 USD/mo
resource "aws_ssm_parameter" "rds_dbowner_password" {
  name  = "app_rds_password_${var.db_name}_${var.environment}"
  type  = "SecureString"
  value = data.aws_secretsmanager_random_password.db_password_init.random_password
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "rds_dbuser_password" {
  name  = "app_rds_rw_password_${var.db_name}_${var.environment}"
  type  = "SecureString"
  value = data.aws_secretsmanager_random_password.db_password_init.random_password
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "rds_dbviewer_password" {
  name  = "app_rds_ro_password_${var.db_name}_${var.environment}"
  type  = "SecureString"
  value = data.aws_secretsmanager_random_password.db_password_init.random_password
  lifecycle {
    ignore_changes = [value]
  }
}

resource "postgresql_role" "db_owner" {
  name     = "${var.owner_name}_${var.environment}"
  login    = true
  password = aws_ssm_parameter.rds_dbowner_password.value
}

resource "postgresql_database" "db" {
  name  = "${var.db_name}_${var.environment}"
  owner = postgresql_role.db_owner.name
}

resource "postgresql_role" "db_user" {
  count    = var.user_name != "" ? 1 : 0
  name     = "${var.user_name}_${var.environment}"
  login    = true
  password = aws_ssm_parameter.rds_dbuser_password.value
}

resource "postgresql_grant" "user" {
  count       = var.user_name != "" ? 1 : 0
  database    = postgresql_database.db.name
  role        = postgresql_role.db_user[0].name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_role" "db_viewer" {
  count    = var.viewer_name != "" ? 1 : 0
  name     = "${var.viewer_name}_${var.environment}"
  login    = true
  password = aws_ssm_parameter.rds_dbviewer_password.value
}

resource "postgresql_grant" "viewer" {
  count       = var.user_name != "" ? 1 : 0
  database    = postgresql_database.db.name
  role        = postgresql_role.db_viewer[0].name
  object_type = "table"
  privileges  = ["SELECT"]
}
