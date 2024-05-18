variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
  default     = ""
}
