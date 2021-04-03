variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}

variable "execution_role_arn" {
  type        = string
  description = "Pre-created ECS task execution role with policy for accessing other AWS resources"
}