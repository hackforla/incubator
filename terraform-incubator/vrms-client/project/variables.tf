variable "environment" {
    type = string
}
variable "backend_host" {
    type = string
}
variable "client_url" {
    type = string
}
variable "react_app_proxy" {
    type = string
}
variable "host_names" {
    type = list(string)
}
variable "root_db_password" {
  type        = string
  description = "root database password"
}

variable "app_db_password" {
  type = string
}

variable "container_image" {
  type = string
}