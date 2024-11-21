variable "shared_configuration" {
  description = "Configuration object from shared resources"
  type = object({
    alb_https_listener_arn = string
    cluster_id             = string
    cluster_name           = string
    vpc_id                 = string
    public_subnet_ids      = set(string)
  })
}

variable "project_name" {
  description = "The overall name of the project using this infrastructure; used to group related resources by"
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "launch_type" {
  default     = "FARGATE"
  type        = string
  description = "How to launch the container within ECS EC2 instance or FARGATE"
}

variable "application_type" {
  type        = string
  description = "defines what type of application is running, fullstack, client, backend, etc. will be used for cloudwatch logs"
}

variable "task_role_arn" {
  type = string
}

variable "fargate_security_group_id" {
  type = string
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

variable "container_secrets" {
  type = map(any)
}

variable "desired_count" {
  default = 1
  type    = number
}

variable "host_names" {
  type    = list(string)
  default = []
}

variable "path_patterns" {
  type    = list(string)
  default = []
}

variable "health_check_path" {
  type = string
}

variable "log_group" {
  type = string
}

variable "service_discovery_dns_namespace_id" {
  type = string
}
