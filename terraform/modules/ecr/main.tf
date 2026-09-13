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

variable "force_delete" {
  type        = bool
  default     = false
  description = "Allow Terraform to destroy the repository while it still holds images, destroying them with it. Without it the destroy fails with RepositoryNotEmptyException. Set it only on a repository about to be removed, and apply that before removing the module call."
}

resource "aws_ecr_repository" "this" {
  name                 = coalesce(var.repository_name, var.project_name)
  image_tag_mutability = "MUTABLE"
  force_delete         = var.force_delete
  tags = {
    project = var.project_name
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}
