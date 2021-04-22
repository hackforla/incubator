variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}

variable "execution_role_arn" {
  type        = string
  description = "ECS task execution role with policy for accessing other AWS resources"
}

variable "default_ecs_service_role_arn" {
  type        = string
  description = "AWS service linked role created for default all ecs services"
}
