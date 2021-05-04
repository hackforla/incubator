module "ecr" {
  source = "../ecr"

  project_name = "${var.project_name}-${var.application_type}"
  environment  = var.environment
}