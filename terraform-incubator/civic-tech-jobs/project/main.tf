module "civic_tech_jobs" {
  source = "../../../terraform-modules/service"
  project_name      = "civic-tech-jobs"
  region            = "us-west-2"
  environment       = "dev"
  application_type  = "backend"
  tags = {
    last_changed      = "Wed 2023-Jun-14 18:08:34"
    terraform_managed = "true"
  }
  container_image = var.container_image
}

variable "container_image" {
  type = string
}
