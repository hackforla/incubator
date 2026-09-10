module "ecr_backend" {
   source = "../../modules/ecr"
   project_name = local.project_name
   repository_name = "vrms-backend"
} 

module "ecr_frontend" {
   source = "../../modules/ecr"
   project_name = local.project_name
   repository_name = "vrms-frontend"
} 