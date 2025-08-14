import {
  to = aws_db_instance.default
  id = "incubator-prod-database"
}


resource "aws_db_instance" "default" {
  allocated_storage                     = 100
  apply_immediately                     = true
  auto_minor_version_upgrade            = true
  availability_zone                     = "us-west-2a"
  backup_retention_period               = 0
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
  engine_version                        = "13.20"
  iam_database_authentication_enabled   = false
  identifier                            = "incubator-prod-database"
  instance_class                        = "db.t3.small"
  multi_az                              = false
  network_type                          = "IPV4"
  option_group_name                     = "default:postgres-13"
  parameter_group_name                  = "default.postgres13"
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
