module "people_depot_ecr_backend" {
   source = "../../modules/ecr"
   project_name = "${local.project_name}-fullstack"
} 