terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.21.0"
    }
  }
}

data "aws_secretsmanager_random_password" "db_password_init" {
  password_length = 48
}

data "aws_db_instance" "shared" {
  db_instance_identifier = var.shared_configuration.db_identifier
}

// We're using the random_password data source to initialize this;
// we use the lifecycle.ignore_changes to say that we don't want
// the value to be updated. We get most of the benefit of a
// Secret Manager entry, and save 0.40 USD/mo
resource "aws_ssm_parameter" "rds_dbowner_password" {
  name  = "rds_password_${var.postgres_database.db_name}_${var.environment}"
  type  = "String"
  value = data.aws_secretsmanager_random_password.db_password_init.random_password
  lifecycle {
    ignore_changes = [value]
  }
}

resource "postgresql_role" "db_owner" {
  count    = var.postgres_database.username != "" ? 1 : 0
  name     = "${var.postgres_database.username}_${var.environment}"
  login    = true
  password = aws_ssm_parameter.rds_dbowner_password.value
}

resource "postgresql_database" "db" {
  count = var.postgres_database.db_name != "" ? 1 : 0
  name  = "${var.postgres_database.db_name}_${var.environment}"
  owner = postgresql_role.db_owner[0].name
}
