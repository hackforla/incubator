resource "aws_security_group" "db" {
  name        = "${local.envname}-database"
  description = "Ingress and egress for ${local.envname} RDS"
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-database", local.envname)
    },
  )

  ingress {
    description = "db ingress from vpc"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.db_public_access ? "0.0.0.0/0" : var.vpc_cidr]
  }

  egress {
    description = "global egress"
    from_port   = 22
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
