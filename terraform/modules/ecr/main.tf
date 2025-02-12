// XXX Decommision - not enough here to merit separate module
// --------------------------
// General Variables
// --------------------------

variable "project_name" {
  type        = string
  description = "The overall name of the project using this infrastructure; used to group related resources by"
}

// --------------------------
// Elastic Container Repository
// --------------------------
resource "aws_ecr_repository" "this" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
