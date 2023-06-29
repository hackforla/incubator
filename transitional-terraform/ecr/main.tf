// --------------------------
// General Variables
// --------------------------
locals {
  envname = "${var.project_name}-${var.environment}"
}

variable "project_name" {
  type        = string
  description = "The overall name of the project using this infrastructure; used to group related resources by"
}

variable "environment" {
  type = string
}

// --------------------------
// Elastic Container Repository
// --------------------------
resource "aws_ecr_repository" "this" {
  name                 = local.envname
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
