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