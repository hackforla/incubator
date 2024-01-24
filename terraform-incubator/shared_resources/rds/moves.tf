moved {
  from = aws_db_instance.this[0]
  to   = module.rds.aws_db_instance.this[0]
}
moved {
  from = aws_db_subnet_group.this
  to   = module.rds.aws_db_subnet_group.this
}
moved {
  from = aws_security_group.db
  to   = module.rds.aws_security_group.db
}
