locals {
  envname                = "${var.project_name}-${var.environment}"
  envappname             = "${var.project_name}-${var.application_type}-${var.environment}"
}

// --------------------------
// Global/General Variables
// --------------------------
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
  type        = string
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

variable "https_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https_listener_index (default to https_listeners[count.index])"
  type        = any
  default     = []
}

variable "path_patterns" {
  type    = list(string)
  default = []
}

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
  type = map(any)
}

variable "postgres_database" {
  type        = map(string)
  default     = {}
  description = "non-empty map will invoke lambda function to create database and users for application"
}

variable "lambda_function" {
  type        = string
  description = "name of the multi-db lambda function"
}

variable "db_instance_endpoint" {
  type        = string
  description = "multi-tenant database endpoint, include host and port"
}

variable "root_db_username" {
  type        = string
  description = "root database user"
}

variable "root_db_password" {
  type        = string
  description = "root database password"
}
