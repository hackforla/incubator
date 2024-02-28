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

variable "gmail_client_id" {
    type = string
}
variable "gmail_secret_id" {
    type = string
    sensitive = true
}
variable "gmail_refresh_token" {
    type = string
    sensitive = true
}

variable "mailhog_password" {
    type = string
    sensitive = true
}

variable "slack_client_id" {
    type = string
}
variable "slack_client_secret" {
    type = string
    sensitive = true
}
variable "slack_oauth_token" {
    type = string
    sensitive = true
}
variable "slack_signing_secret" {
    type = string
    sensitive = true
}
variable "slack_bot_token" {
    type = string
    sensitive = true
}