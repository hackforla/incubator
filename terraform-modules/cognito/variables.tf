variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
}

variable "client_name" {
  description = "Name of the Cognito User Pool Client"
  type        = string
}
