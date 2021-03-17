locals {
  envname                = "${var.project_name}-${var.environment}"
  ecs_service_name       = "${local.envname}-service"
  task_definition_family = "${local.envname}-td"
  task_name              = "${local.envname}-task"
  container_name         = "${local.envname}-container"
}

// --------------------------
// Global/General Variables
// --------------------------
variable "account_id" {
  description = "AWS Account ID"
}

variable "project_name" {
  description = "The overall name of the project using this infrastructure; used to group related resources by"
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "application_type" {
  type = string
  description = "defines what type of application is running, fullstack, client, backend, etc. will be used for cloudwatch logs"
}
variable "host_names" {
  type = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC cidr block"
}

variable "public_subnet_ids" {
  description = "Public Subnets IDs"
  type        = list(string)
}

variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}

// --------------------------
// ECS Cluster
// --------------------------

variable "cluster_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

// --------------------------
// Application Load Balancer
// --------------------------

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "alb_https_listener_arn" {
  description = "ALB https listener arn for adding rule to"
}

variable "alb_security_group_id" {
  description = "ALB Security Group ID"
  type        = string
}
// --------------------------
// Container Definition Variables
// --------------------------

variable "desired_count" {
  default = 1
  type    = number
}

variable "launch_type" {
  default     = "FARGATE"
  type        = string
  description = "How to launch the container within ECS EC2 instance or FARGATE"
}

variable "task_execution_role_arn" {
  type        = string
  description = "ECS task execution role with policy for accessing other AWS resources"
}

variable "container_image" {
  type = string
}

variable "container_cpu" {
  type    = number
  default = 0
}

variable "container_memory" {
  type    = number
  default = 0
}

variable "container_port" {
  type    = number
  default = 80
}

variable "container_env_vars" {
  type = map(string)
}
