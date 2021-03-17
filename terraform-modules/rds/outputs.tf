output "db_address" {
  description = "The aws provided URL of the database"
  value       = module.db.this_db_instance_address
}

output "db_instance_hosted_zone_id" {
  value = module.db.this_db_instance_hosted_zone_id
}

output "db_instance_endpoint" {
  description = "The db adress and port for this RDS instance"
  value       = module.db.this_db_instance_endpoint
}

output "db_security_group_id" {
  description = "The security group id for this RDS instance"
  value       = aws_security_group.db.id
}
