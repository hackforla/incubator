module "ecr" {
  source = "../ecr"

  project_name = var.project_name
  environment = var.environment
}
