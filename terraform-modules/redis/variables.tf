locals {
  envname                = "${var.resource_name}-${var.environment}"
  ecs_service_name       = "${var.resource_name}-${var.environment}-redis"
  task_definition_family = "${var.resource_name}-${var.environment}-redis"
  task_name              = "${var.resource_name}-${var.environment}-redis"
  container_name         = "${var.resource_name}-${var.environment}-redis"
}
// --------------------------
// Global/General Variables
// --------------------------
variable account_id {
  description = "AWS Account ID"
}

variable resource_name {
  description = "The overall name of the project using this infrastructure; used to group related resources by"
}

variable region {
  type    = string
  default = "us-east-2"
}

variable environment {
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
}

variable tags {
  default = { terraform_managed = "true" }
  type    = map
}

// --------------------------
// ECS/Fargat Variables
// --------------------------
variable container_cpu {
  type    = number
  default = 256
}

variable container_memory {
  type    = number
  default = 0
}

variable container_port {
  type    = number
  default = 0
}

variable "cluster_id" {
  type = string
}

variable cluster_name {
  type = string
}

variable desired_count {
  default = 1
  type    = number
}

variable public_subnet_ids {
  description = "VPB Public Subnets for where to place Fargate tasks"
  type        = list(string)
}

variable "private_dns_id" {
  type = string
}