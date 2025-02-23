// project name, used across all envs
locals {
    project_name_civic_tech_jobs = "civic-tech-jobs"
}

module "civic_tech_jobs_ecr_fullstack" {
   source = "../../modules/ecr"
   project_name = "${local.project_name_civic_tech_jobs}-fullstack"
} 

module "civic_tech_jobs_cicd" {
    source = "../../modules/cicd_integration"
    project_name = local.project_name_civic_tech_jobs
    repository_name = "CivicTechJobs"
}
