module "ecr_fullstack" {
   source = "../../modules/ecr"
   project_name = "${local.project_name}-fullstack"
}

// The production image repository, adopted as a plain resource rather than through
// modules/ecr. That module derives the repository name from the project name, which
// would make this `home-unite-us`; the repository predates that convention and its
// name is referenced by the running production task definition and by the project's
// own CI, so it cannot be renamed without breaking both. See hackforla/incubator#166.
resource "aws_ecr_repository" "homeuniteus_prod" {
  name                 = "homeuniteus"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
