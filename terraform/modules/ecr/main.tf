/**
 * # ecr
 *
 * This creates a standard Elastic Container Registry docker registry.
 * 
 */


variable "project_name" {
  type        = string
  description = "HfLA project name (vrms, home-unite-us, etc)"
}

resource "aws_ecr_repository" "this" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
