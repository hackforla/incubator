output "security_group_id" {
  description = "the security group id of the bastion server. Add this id to other services that run within the vpc to which you want to access externally."
  value       = aws_security_group.bastion.id
}

output "bastion_hostname" {
  description = "The URL to access the bastion server"
  value       = var.bastion_hostname
}
