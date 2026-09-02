# Not consumed yet. They exist so replacing the literals in modules/container and
# database.tf becomes a rename rather than a re-derivation.

output "cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "the ECS cluster name -- hardcoded today as `cluster` in modules/container"
}

output "cluster_arn" {
  value       = aws_ecs_cluster.this.arn
  description = "the ECS cluster arn"
}

output "capacity_provider_name" {
  value       = aws_ecs_capacity_provider.ec2.name
  description = "the EC2 capacity provider, `incubator-proc-ec2` -- the typo is the real name"
}

output "vpc_id" {
  value       = aws_vpc.this.id
  description = "the platform VPC -- hardcoded today in modules/container twice"
}

output "vpc_cidr_block" {
  value       = aws_vpc.this.cidr_block
  description = "the VPC CIDR -- hardcoded today as the container ingress rule's source"
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "the two public subnets, holding the load balancer, NAT gateway and RDS instance"
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private : s.id]
  description = "the two private subnets -- hardcoded today as the ECS service network configuration"
}

output "alb_arn" {
  value       = aws_lb.this.arn
  description = "the load balancer arn"
}

output "alb_name" {
  value       = aws_lb.this.name
  description = "the load balancer name -- looked up today through a data source in modules/dns-entry"
}

output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "the alias target for every project's Route 53 record"
}

output "alb_zone_id" {
  value       = aws_lb.this.zone_id
  description = "the load balancer's hosted zone id, needed alongside `alb_dns_name` for an alias"
}

output "https_listener_arn" {
  value       = aws_lb_listener.https.arn
  description = "the HTTPS listener -- hardcoded today on every listener rule in modules/container"
}

output "http_listener_arn" {
  value       = aws_lb_listener.http.arn
  description = "the HTTP listener, which only redirects to HTTPS"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "the load balancer's security group"
}

output "database_security_group_id" {
  value       = aws_security_group.database.id
  description = "the shared RDS group -- hardcoded today as `vpc_security_group_ids` in database.tf"
}

output "ecs_task_execution_role_arn" {
  value       = aws_iam_role.ecs_task_execution.arn
  description = "the role tasks pull images and write logs as -- hardcoded today in modules/container"
}

output "ecs_instance_role_arn" {
  value       = aws_iam_role.ecs_instance.arn
  description = "the role the ECS container instances run as"
}
