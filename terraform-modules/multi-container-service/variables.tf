locals {
  envname          = "${var.project_name}-${var.environment}"
  envappname       = "${var.project_name}-${var.application_type}-${var.environment}"
  discovery_domain = "${local.envname}.local"
}

# c.f. terraform-incubator shared_configuration/all
# XXX We'd like to reduce this to ARNs and IDs and just use `data` blocks
variable "shared_configuration" {
  description = "Configuration object from shared resources"
  type = object({
    alb_arn                 = string
    alb_https_listener_arn  = string
    cluster_id              = string
    cluster_name            = string
    task_execution_role_arn = string
    db_identifier           = string
    vpc_id                  = string
    public_subnet_ids       = set(string)
  })
}

variable "region" {
  type = string
}

variable "project_name" {
  description = "The overall name of the project using this infrastructure; used to group related resources"
}

variable "application_type" {
  type        = string
  description = "defines what type of application is running, fullstack, client, backend, etc. will be used for cloudwatch logs"
}

variable "environment" {
  type = string
}

variable "zone_id" {
  type        = string
  description = "The root zone_id for the service"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC cidr block"
}

variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}

// --------------------------
// Container Definition Variables
// --------------------------

variable "containers" {
  type = map(object({
    tag               = optional(string, "latest")
    desired_count     = optional(number, 1)
    launch_type       = optional(string, "FARGATE")
    cpu               = optional(number, 0)
    memory            = optional(number, 0)
    port              = optional(number, 80)
    subdomains        = optional(list(string), [])
    path_patterns     = optional(list(string), [])
    health_check_path = optional(string, "/")
    env_vars          = optional(map(any), {})
    secrets           = optional(map(any), {})
  }))

  description = "Per container service configuration. Note that subdomains are used (e.g. 'www' not 'www.example.com')"
}
