# RDS rejects a major version upgrade that keeps a parameter group from the old
# engine family, and AWS creates default groups lazily -- default.postgres15
# does not exist in this account. A managed group also gives future tuning
# somewhere to live.
#
# password_encryption is deliberately left unset: postgres15 sets no value, so
# the engine default (scram-sha-256) applies to roles created after the upgrade.
# See hackforla/incubator#150 for the decision.
resource "aws_db_parameter_group" "postgres15" {
  name        = "incubator-prod-postgres15"
  family      = "postgres15"
  description = "incubator-prod-database, PostgreSQL 15"

  tags = {
    Name              = "incubator-prod-postgres15"
    terraform_managed = "true"
  }
}

# option_group_name is deliberately absent. Option groups do nothing for
# PostgreSQL, and AWS creates the default ones lazily -- naming
# "default:postgres-15" before it exists fails the apply with
# OptionGroupNotFoundFault. Leaving the attribute out lets RDS assign the
# family default itself during the major upgrade. Do not add it back.
resource "aws_db_instance" "default" {
  allocated_storage                     = 100
  allow_major_version_upgrade           = true
  apply_immediately                     = true
  auto_minor_version_upgrade            = true
  availability_zone                     = "us-west-2a"
  backup_retention_period               = 4
  backup_target                         = "region"
  backup_window                         = "03:00-06:00"
  ca_cert_identifier                    = "rds-ca-rsa2048-g1"
  copy_tags_to_snapshot                 = true
  customer_owned_ip_enabled             = false
  db_subnet_group_name                  = "incubator-prod"
  deletion_protection                   = false
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  engine                                = "postgres"
  engine_lifecycle_support              = "open-source-rds-extended-support"
  engine_version                        = "15"
  iam_database_authentication_enabled   = false
  identifier                            = "incubator-prod-database"
  instance_class                        = "db.t3.small"
  multi_az                              = false
  network_type                          = "IPV4"
  parameter_group_name                  = aws_db_parameter_group.postgres15.name
  port                                  = 5432
  publicly_accessible                   = true
  skip_final_snapshot                   = true
  storage_encrypted                     = false
  storage_type                          = "gp2"

  tags = {
    Name              = "incubator-prod-database"
    terraform_managed = "true"
  }

  username               = "postgres"

  vpc_security_group_ids = ["sg-0ab8947eeb3d705ac"]
}
