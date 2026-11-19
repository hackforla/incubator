variable "name" {
  type        = string
  description = "name of the IAM policy. Policy names are unique per account, so include the project and environment, for example `food-oasis-prod-ses-send`"
}

variable "task_role_name" {
  type        = string
  description = "name of the container's task role, from the `container` module's `task_role_name` output"
}

variable "identity_arns" {
  type        = list(string)
  description = "ARNs of the SES identities the container may send from, for example the `ses` module's `arn` output. Each must be the identity of a From address the application uses, or that address's domain"

  validation {
    condition     = length(var.identity_arns) > 0
    error_message = "identity_arns must list at least one SES identity ARN."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "tags for the policy, on top of the provider's default tags. Pass the project's `project` tag here"
}
