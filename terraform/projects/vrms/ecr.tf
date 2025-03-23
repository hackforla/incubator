module "ecr_backend" {
   source = "../../modules/ecr"
   project_name = "${local.project_name}-backend"
} 

module "ecr_frontend" {
   source = "../../modules/ecr"
   project_name = "${local.project_name}-frontend"
} 