// One image repository shared by both environments, which are told apart by tag.
module "food_oasis_ecr_fullstack" {
  source          = "../../modules/ecr"
  project_name    = local.project_name_food_oasis
  repository_name = "food-oasis-fullstack"
}

module "food_oasis_cicd" {
  source          = "../../modules/cicd_integration"
  project_name    = local.project_name_food_oasis
  repository_name = "food-oasis"
}
