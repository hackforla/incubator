locals {
  azs = ["us-west-2a", "us-west-2b"]

  # The Terragrunt-era tags these resources carry live are deliberately dropped rather than
  # adopted: they name a state file that no longer exists. The apply removes them.
  legacy_tags = {
  }

  public_subnet_cidrs = {
    "us-west-2a" = "10.10.3.0/24"
    "us-west-2b" = "10.10.4.0/24"
  }

  private_subnet_cidrs = {
    "us-west-2a" = "10.10.1.0/24"
    "us-west-2b" = "10.10.2.0/24"
  }
}

# Holds the load balancer, the NAT gateway and the RDS instance.
resource "aws_subnet" "public" {
  for_each = local.public_subnet_cidrs

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true # the only thing that makes these the public pair

  tags = merge(local.legacy_tags, {
    Name = "incubator-prod-vpc-public-${each.key}"
  })
}

# Holds both container instances and every ECS task, reaching out through the NAT gateway.
resource "aws_subnet" "private" {
  for_each = local.private_subnet_cidrs

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge(local.legacy_tags, {
    Name = "incubator-prod-vpc-private-${each.key}"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.legacy_tags, {
    Name = "incubator-prod-vpc"
  })
}

# The only elastic IP Terraform can own; the other two belong to the ELB service.
resource "aws_eip" "nat" {
  domain = "vpc"
}

# One NAT gateway for both private subnets: losing us-west-2a costs both zones their
# outbound internet. Inherited from the 2021 build, recorded rather than changed.
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["us-west-2a"].id

  tags = {
    Name = "incubator-prod"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.legacy_tags, {
    Name = "incubator-prod-vpc-public"
  })
}

# One table per private subnet, both pointing at the same NAT gateway. Collapsing them into
# one would be a live change.
resource "aws_route_table" "private" {
  for_each = toset(local.azs)

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(local.legacy_tags, {
    Name = "incubator-prod-vpc-private-${each.key}"
  })
}

# The VPC's main table: created with the VPC, so `aws_default_route_table`, not
# `aws_route_table`. It carries no tags live and deliberately gets none here.
resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  route = [] # no routes beyond the implicit local one; omitting this would leave them unmanaged
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
