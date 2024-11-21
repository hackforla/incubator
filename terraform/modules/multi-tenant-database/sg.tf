resource "aws_security_group" "this" {
  name        = "${local.envname}-db-lambda"
  description = "Ingress and egress for ${local.envname} lambda function"
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-database", local.envname)
    },
  )

  ingress {
    description = "db ingress from vpc"
    from_port   = 0
    to_port     = 65535
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
