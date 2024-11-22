output "db_identifier" {
  description = "The AWS provided identifier"
  value       = aws_db_instance.this[0].identifier
}

output "db_address" {
  description = "The aws provided URL of the database"
  value       = element(concat(aws_db_instance.this.*.address, [""]), 0)
}

output "db_instance_hosted_zone_id" {
  value = element(concat(aws_db_instance.this.*.hosted_zone_id, [""]), 0)
}

output "db_instance_endpoint" {
  description = "The db adress and port for this RDS instance"
  value       = element(concat(aws_db_instance.this.*.endpoint, [""]), 0)
}

output "db_security_group_id" {
  description = "The security group id for this RDS instance"
  value       = aws_security_group.db.id
}
