resource "aws_security_group" "alb" {
  name        = "incubator-prod-alb"
  description = "load balancer SG for ingress to incubator-prod containers"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "incubator-prod-alb"

    # Terragrunt-era, from a state file that no longer exists. Adopted, not believed.
    terraform_managed = "true"
    last_changed      = "Thu 2023-Sep-28 06:13:14"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from world"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from world"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  description       = "allow outbound traffic to the world"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# The shared RDS instance's group. `database.tf` still names it by literal id.
resource "aws_security_group" "database" {
  name        = "incubator-prod-database"
  description = "Ingress and egress for incubator-prod RDS"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "incubator-prod-database"

    # Terragrunt-era, from a state file that no longer exists. Adopted, not believed.
    terraform_managed = "true"
    last_changed      = "Sat 2021-May-08 20:09:49"
  }
}

# The description says "from vpc" but the CIDR is the internet, and the instance it guards is
# publicly_accessible in a public subnet. Reproduced as deployed; fixing it is separate work.
resource "aws_vpc_security_group_ingress_rule" "database_postgres" {
  security_group_id = aws_security_group.database.id
  description       = "db ingress from vpc"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
}

# A database does not initiate connections, and a range starting at 22 looks copied from a
# bastion rule. Reproduced as deployed; fixing it is separate work.
resource "aws_vpc_security_group_egress_rule" "database_all" {
  security_group_id = aws_security_group.database.id
  description       = "global egress"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 65535
  ip_protocol       = "tcp"
}

# Where the ECS container instances actually run. Rules must stay inline: this resource type
# revokes anything not declared, so splitting them out would strip what the instances need.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  # All traffic from anywhere, far from the AWS default of self-referencing ingress. The
  # instances are in private subnets so it is not reachable, but it deserves a separate fix.
  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
