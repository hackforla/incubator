variable "user_pool_id" {
  type        = string
  description = "id of the shared user pool, from aws_cognito_user_pool.shared in terraform/cognito.tf"
}

variable "user_pool_arn" {
  type        = string
  description = "ARN of the shared user pool, the resource the admin policy is scoped to"
}

variable "clients" {
  type = map(object({
    name                                 = string
    generate_secret                      = optional(bool, false)
    explicit_auth_flows                  = optional(list(string), ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"])
    supported_identity_providers         = optional(list(string))
    callback_urls                        = optional(list(string))
    allowed_oauth_flows                  = optional(list(string))
    allowed_oauth_scopes                 = optional(list(string))
    allowed_oauth_flows_user_pool_client = optional(bool, false)
  }))
  description = "this project's app clients in the shared pool, keyed by a short stable name. `name` is the client name Cognito shows, which is also what an application sees."
}

variable "task_role_name" {
  type        = string
  default     = null
  description = "name of the project's task role, to grant it Cognito admin operations on the shared pool. Leave unset if the project only signs users in."
}
