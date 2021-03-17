resource "aws_ecr_repository" "this" {
  name                 = local.envname
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}