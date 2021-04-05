locals {
  db_subnet_ids = var.db_public_access ? var.public_subnet_ids : var.private_subnet_ids
}
resource "aws_db_instance" "this" {
  count = var.create_db_instance ? 1 : 0

  identifier = "${local.envname}-database"

  engine            = "postgres"
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = 100

  username                            = var.db_username
  password                            = var.db_password
  port                                = var.db_port

  publicly_accessible    = var.db_public_access
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  // parameter_group_name   = "postgres${var.db_major_version}"
  // option_group_name      = var.db_major_version

  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  maintenance_window          = "Mon:00:00-Mon:03:00"

  snapshot_identifier   = var.db_snapshot_migration
  copy_tags_to_snapshot = true
  skip_final_snapshot   = true

  backup_retention_period = 0
  backup_window           = "03:00-06:00"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  deletion_protection      = false
  delete_automated_backups = false

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-database", local.envname)
    },
  )
}

resource "aws_db_subnet_group" "this" {
  name        = local.envname
  subnet_ids  = local.db_subnet_ids

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", local.envname)
    },
  )
}