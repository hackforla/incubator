// --------------------------
// General Variables
// --------------------------
locals {
  envname = "${var.application}-${var.environment}"
}

variable "application" {
  type        = string
  description = "The overall name of the project using this infrastructure; used to group related resources by"
}

variable "environment" {
  type = string
}

variable "repos" {
  type = list(string)
}

// --------------------------
// Elastic Container Repository
// --------------------------
resource "aws_ecr_repository" "this" {
  for_each = toset(var.repos)

  name                 = "${local.envname}-${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
