module "ecr_fullstack" {
   source = "../../modules/ecr"
   project_name = "${local.project_name}-fullstack"
} 