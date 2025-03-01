
module "cicd_integration" {
    source = "../../modules/cicd_integration"
    project_name = local.project_name
    repository_name = "HomeUniteUs"
}