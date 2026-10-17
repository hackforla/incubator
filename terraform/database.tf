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
    Name = "incubator-prod-postgres15"
  }
}

# The instance sits in the two public subnets the platform module owns, which is why
# subnet_ids reads them from its output rather than repeating the ids.
#
# description is ForceNew: RDS cannot change it in place, so a value that does not match
# what is live plans a REPLACEMENT of the subnet group the production database sits in.
# "Managed by Terraform" is a Terragrunt-era leftover and is the live value, so it is
# declared verbatim. prevent_destroy makes any such replacement fail loudly instead.
#
# The live group also carried terraform_managed and last_changed tags from the same era.
# Both are dropped here -- managed-by, set by the provider's default_tags, is the real
# signal, and last_changed had read "Sat 2021-May-08 20:09:49" for five years.
# See hackforla/incubator#214.
resource "aws_db_subnet_group" "incubator_prod" {
  name        = "incubator-prod"
  description = "Managed by Terraform"
  subnet_ids  = module.platform.public_subnet_ids

  tags = {
    Name = "incubator-prod"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# The original 100 GiB instance. hackforla/incubator#267 swapped it out by identifier
# for the 20 GiB instance below, so it is now "incubator-prod-database-old". destroy =
# false stops managing it without deleting it; it is deleted by hand, with a final
# snapshot, once the new instance has run cleanly for a few days.
removed {
  from = aws_db_instance.default

  lifecycle {
    destroy = false
  }
}

# The shared instance, on a 20 GiB volume since hackforla/incubator#267. RDS cannot
# shrink allocated storage, so it was created as "incubator-prod-database-new", filled
# by pg_dump/pg_restore, and then swapped identifiers with the original 100 GiB
# instance. That kept the endpoint hostname -- and every connection URL -- unchanged.
#
# gp3 rather than gp2: gp2 baseline IOPS scale with size (3 per GiB, minimum 100),
# so 20 GiB of gp2 would drop from 300 to 100 IOPS. gp3 is a flat 3,000 at the
# same price. With max_allocated_storage set, the provider ignores the difference
# from allocated_storage once autoscaling grows the volume.
#
# The master password reuses var.pgpassword, so TF_VAR_PGPASSWORD stays valid.
# password_wo keeps it out of state; bump password_wo_version to push a new one.
#
# option_group_name is deliberately absent. Option groups do nothing for
# PostgreSQL, and AWS creates the default ones lazily -- naming
# "default:postgres-15" before it exists fails the apply with
# OptionGroupNotFoundFault. Leaving the attribute out lets RDS assign the
# family default itself. Do not add it back.
resource "aws_db_instance" "incubator_prod" {
  allocated_storage                   = 20
  allow_major_version_upgrade         = true
  apply_immediately                   = true
  auto_minor_version_upgrade          = true
  availability_zone                   = "us-west-2a"
  backup_retention_period             = 4
  backup_target                       = "region"
  backup_window                       = "03:00-06:00"
  ca_cert_identifier                  = "rds-ca-rsa2048-g1"
  copy_tags_to_snapshot               = true
  customer_owned_ip_enabled           = false
  db_subnet_group_name                = aws_db_subnet_group.incubator_prod.name
  deletion_protection                 = false
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  engine                              = "postgres"
  engine_lifecycle_support            = "open-source-rds-extended-support"
  engine_version                      = "15"
  iam_database_authentication_enabled = false
  identifier                          = "incubator-prod-database"
  instance_class                      = "db.t3.small"
  max_allocated_storage               = 50
  multi_az                            = false
  network_type                        = "IPV4"
  parameter_group_name                = aws_db_parameter_group.postgres15.name
  password_wo                         = var.pgpassword
  password_wo_version                 = 1
  port                                = 5432
  publicly_accessible                 = true
  skip_final_snapshot                 = true
  storage_encrypted                   = false
  storage_type                        = "gp3"

  tags = {
    Name = "incubator-prod-database"
  }

  username = "postgres"

  vpc_security_group_ids = ["sg-0ab8947eeb3d705ac"]

  lifecycle {
    prevent_destroy = true
  }
}

# RDS creates these two because the instance sets enabled_cloudwatch_logs_exports.
# Neither had any retention at all, so postgresql had accumulated 964 MB since 2021 and
# would never have expired. 180 days is the agreed window; note that applying it deletes
# everything older, which is the point of the change rather than a side effect.
#
# One resource with for_each rather than two resources, so a single import block covers
# both -- Terraform honours one import block per resource ADDRESS, not per instance.
#
# RDSOSMetrics is deliberately not declared. Enhanced Monitoring is off, that group is
# empty and already has retention, and whether it should exist belongs to
# hackforla/incubator#117. See hackforla/incubator#214.
resource "aws_cloudwatch_log_group" "database" {
  for_each = toset(["postgresql", "upgrade"])

  name              = "/aws/rds/instance/incubator-prod-database/${each.key}"
  retention_in_days = 180

  lifecycle {
    prevent_destroy = true
  }
}
