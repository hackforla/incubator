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

variable "repository_name" {
  type        = string
  default     = null
  description = "Repository name, for repositories whose name predates the project naming convention. Defaults to project_name."
}

resource "aws_ecr_repository" "this" {
  name                 = coalesce(var.repository_name, var.project_name)
  image_tag_mutability = "MUTABLE"
  tags = {
    project = var.project_name
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}
