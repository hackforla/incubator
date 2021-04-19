locals {
  envname = "${var.resource_name}-${var.environment}"
}

// --------------------------
// General Variables
// --------------------------
variable "resource_name" {
  type        = string
  description = "The overall name of the shared resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}

// --------------------------
// Application Load Balancer Variables
// --------------------------

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public Subnets for which the ALB will be associated with"
}

variable "acm_certificate_arns" {
  type        = list(string)
  description = "Certificates to use for HTTPS listener"
}

variable "default_alb_url" {
  type        = string
  description = "Default URL to forward the user if there is no ALB route rules that match"
}
