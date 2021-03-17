locals {
  environment  = "test"
  host_names         = ["fight.foodoasis.net"]
  project_name = "fighting-game"

  // Container variables
  application_type = "fullstack"
  launch_type       = "FARGATE"
  container_image  = "darpham/fighting-game:latest"
  desired_count    = 1
  container_port   = 80
  container_memory = 256
  container_cpu    = 0
  health_check_path = "/"

  container_env_vars = {
  }
}