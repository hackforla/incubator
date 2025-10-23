variable "project_name" {
  description = "The overall name of the project using this infrastructure; used to group related resources by"
}

variable "environment" {
  type = string
}

variable "application_type" {
  type        = string
  description = "defines what type of application is running, fullstack, client, backend, etc. will be used for cloudwatch logs"
}

variable "container_image" {
  description = "The full address of the ECR image used by the container: for example `035866691871.dkr.ecr.us-west-2.amazonaws.com/civictechindex-backend-prod:77845e0`"
  type = string
}

variable "container_cpu" {
  type    = number
  description = "CPU allocation for the container. 1024 is a full vCPU. Typically containers can run on much less"
  default = 256
}

variable "container_memory" {
  type    = number
  description = "memory allocation in MB. 1024 is one full gig of memory"
  default = 1024
}

variable "container_port" {
  type    = number
  description = "what port this container opens up to the outside"
}

variable "container_environment" {
  description = "a list of name/value pairs of environmental variables. example: `{name = 'environment', value = 'production'}`"
  type = list(object({
    name = string
    value = string
  }))
}

variable "container_environment_secrets" {
  description = "similar to `container_environment`, but values are set from secrets. Database credentails and such should use this. example: `{name = 'postgresql_password', valueFrom = (SECRET_ARN)}`. If you are using the `secret` terraform module, the ARN is an output value"
  type = list(object({
    name = string
    valueFrom = string
  }))

  default = []
}

variable listener_priority {
  description = "rule priority for load balancer rules. Make sure that rules with a longer path, `/api/v1/*` have a LOWER priority (evaluated first) than shorter ones, `/*`"
  type = number
}

variable "hostname" {
    description = "hostname for load balancer routing, ex: \"www.vrms.io\""
    type = string
}

variable "path" {
    description = "path for load balancer routing, for example `/api/*`"
    type = string
    default = null
}

variable "health_check_path" {
    description = "path for load balancer health checks. This path should return HTTP 200 if the app is up. This path does not need to follow the prefix of `path`, it can be any path"
    type = string
    default = "/"
}

variable "additional_host_urls" {
    type = list(string)
    description = "if multiple hostnames route to this container. For example, both `www.vrms.io` and `vrms.io`"
    default = []
}

variable "launch_type" {
  description = "infrastructure type, either `ec2` or `fargate`. Always use `ec2` unless you have a good reason"
  type = string
  default = "fargate"

  validation {
    condition     = contains(["ec2", "fargate"], var.launch_type)
    error_message = "Must be either \"ec2\" or \"fargate\"."
  }
}