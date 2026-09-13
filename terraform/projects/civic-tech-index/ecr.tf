# One repository per application codebase, shared by every environment, as vrms-backend
# and people-depot-backend are. repository_name is still needed: without it the module
# would name the repository after the project alone.
module "ecr_backend" {
   source = "../../modules/ecr"
   project_name = local.project_name
   repository_name = "civic-tech-index-backend"
}

# The two per-environment repositories below predate that pattern and are being retired
# by hackforla/incubator#225. They stay until both services pull from ecr_backend by
# digest, then are deleted. An ECR repository cannot be renamed or merged in place --
# renaming replaces it, which would destroy every image it holds.
#
# force_delete is set so the PR that removes these two blocks can destroy them: both
# still hold their 2021 images, and only the deployed one was copied to ecr_backend.
module "ecr_backend_prod" {
   source = "../../modules/ecr"
   project_name = "civictechindex"
   repository_name = "civictechindex-backend-prod"
   force_delete = true
}

module "ecr_backend_stage" {
   source = "../../modules/ecr"
   project_name = "civictechindex"
   repository_name = "civictechindex-backend-stage"
   force_delete = true
}
