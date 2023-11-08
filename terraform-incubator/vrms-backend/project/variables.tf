variable "root_db_password" {
  type        = string
  description = "root database password"
}

variable "container_image" {
  type = string
}

variable "host_names" {
  type = list(string)
  description = "list of host names for route 53 and listener rules"
}

variable "environment" {
  type = string
}

variable "database_url" {
  type = string
  description = "The url for the database which is set as an environment variable"
}