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
  type = string
}

variable "container_cpu" {
  type    = number
  default = 512
}

variable "container_memory" {
  type    = number
  default = 1024
}

variable "container_port" {
  type    = number
}

variable "container_environment" {
  type = list(object({
    name = string
    value = string
  }))
}

variable "container_environment_secrets" {
  type = list(object({
    name = string
    valueFrom = string
  }))

  default = []
}

variable listener_priority {
  type = number
}

variable "hostname" {
    type = string
}

variable "path" {
    type = string
    default = null
}

variable "health_check_path" {
    type = string
    default = "/"
}

variable "additional_host_urls" {
    type = list(string)
    default = []
}