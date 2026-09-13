# One repository per application codebase, shared by every environment, as vrms-backend
# and people-depot-backend are. repository_name is still needed: without it the module
# would name the repository after the project alone.
module "ecr_backend" {
   source = "../../modules/ecr"
   project_name = local.project_name
   repository_name = "civic-tech-index-backend"
}
