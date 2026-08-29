# Repository names are literals, not derived from local.project_name, because they
# predate the rewrite and do not follow it: local.project_name is "civic-tech-index"
# and the container modules use "cti". Renaming an ECR repository replaces it, which
# would destroy every image it holds.
module "ecr_backend_prod" {
   source = "../../modules/ecr"
   project_name = "civictechindex-backend-prod"
}

module "ecr_backend_stage" {
   source = "../../modules/ecr"
   project_name = "civictechindex-backend-stage"
}
