locals {
  envname = "${var.resource_name}-${var.environment}"
}

variable "resource_name" {
  type        = string
  description = "The overall name of the shared resources"
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "ecs_ec2_instance_count" {
  type    = number
  default = 0
}

variable "ecs_ec2_instance_type" {
  type    = string
  default = "t3.small"
}

variable "alb_security_group_id" {
  type = string
}

variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}

variable "key_name" {
  type        = string
  description = "pre-created SSH in AWS for access to the ECS EC2 Instance"
}
