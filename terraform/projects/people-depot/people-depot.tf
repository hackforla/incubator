// project name, used across all envs
locals {
    project_name_people_depot = "people-depot"
}

module "people_depot_ecr_backend" {
   source = "../../modules/ecr"
   project_name = "${local.project_name_people_depot}-backend"
} 

module "people_depot_cicd" {
    source = "../../modules/cicd_integration"
    project_name = local.project_name_people_depot
    repository_name = "peopledepot"
}