resource "aws_security_group" "fargate" {
  name        = "ecs_fargate_${local.envappname}"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.shared_configuration.vpc_id

  ingress {
    description = "All Internal traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ecs_container_instance_${local.envappname}" }
}
