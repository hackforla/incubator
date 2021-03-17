output "public_subnet_cidrs" {
  value = [cidrsubnet(var.vpc_cidr, 8, 3), cidrsubnet(var.vpc_cidr, 8, 4)]
}

output "private_subnet_cidrs" {
  value = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2)]
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}
output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}

output "igw_id" {
  value       = module.vpc.igw_id
  description = "The ID of the Internet Gateway"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "public_route_table_ids" {
  description = "IDs of the created public route tables"
  // value       = aws_route_table.rpublic.id
  value = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "IDs of the created private route tables"
  // value       = aws_route_table.rprivate.id
  value = module.vpc.private_route_table_ids
}

output "availability_zones" {
  description = "List of Availability Zones where subnets were created"
  value       = module.vpc.azs
}
