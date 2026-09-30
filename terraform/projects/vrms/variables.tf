// The shared Cognito user pool in ../../cognito.tf. See hackforla/incubator#17.
variable "shared_user_pool_id" {
  type        = string
  description = "id of the shared Cognito user pool"
}

variable "shared_user_pool_arn" {
  type        = string
  description = "ARN of the shared Cognito user pool"
}
