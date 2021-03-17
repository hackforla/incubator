resource "aws_security_group" "db" {
  name        = "${local.envname}-database"
  description = "Ingress and egress for ${local.envname} RDS"
  vpc_id      = var.vpc_id
  tags        = merge({ Name = "${local.envname}-database" }, var.tags)

  ingress {
    description = "db ingress from vpc"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "global egress"
    from_port   = 22
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "db" {
  // https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/2.20.0
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.20.0"

  identifier = "${local.envname}-database"

  allow_major_version_upgrade = var.db_allow_major_engine_version_upgrade
  engine                      = "postgres"
  engine_version              = var.db_engine_version
  instance_class              = var.db_instance_class
  allocated_storage           = 100

  username = var.db_username
  password = var.db_password
  port     = var.db_port

  snapshot_identifier = var.db_snapshot_migration

  vpc_security_group_ids = [aws_security_group.db.id]

  storage_encrypted  = true
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 0

  tags = var.tags

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = var.private_subnet_ids

  # DB parameter group
  family = "postgres${var.db_major_version}"

  # DB option group
  major_engine_version = var.db_major_version

  # Database Deletion Protection
  deletion_protection = false
}
