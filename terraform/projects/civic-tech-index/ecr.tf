# The repository names predate the project naming convention and do not follow it:
# local.project_name is "civic-tech-index" and the container modules use "cti".
# repository_name keeps the live names, so the project tag can be the project rather
# than the repository. Renaming an ECR repository replaces it, which would destroy
# every image it holds.
module "ecr_backend_prod" {
   source = "../../modules/ecr"
   project_name = "civictechindex"
   repository_name = "civictechindex-backend-prod"
}

module "ecr_backend_stage" {
   source = "../../modules/ecr"
   project_name = "civictechindex"
   repository_name = "civictechindex-backend-stage"
}
