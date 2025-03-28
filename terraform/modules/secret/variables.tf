variable "project_name" {
  type = string
}

variable "application_type" {
  type = string
}

variable "environment" {
  type = string
  default = ""
}

variable "name" {
  type = string
}

variable "length" {
  type    = number
  default = 48
}

variable "value" {
  type = string
  default = null
}