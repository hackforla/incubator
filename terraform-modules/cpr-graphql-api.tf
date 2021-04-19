module "graphqa-api" {
  source = "./service"
  
  // Input from other Modules
  vpc_id                  = module.network.vpc_id
  vpc_cidr                = module.network.vpc_cidr
  public_subnet_ids       = module.network.public_subnet_ids

  alb_https_listener_arn  = module.alb.alb_https_listener_arn
  alb_security_group_id   = module.alb.security_group_id
  cluster_name            = module.ecs.cluster_name
  cluster_id              = module.ecs.cluster_id
  task_execution_role_arn = module.ecs.task_execution_role_arn

  // Input from Variables
  region = var.region
  tags   = var.tags

  environment   = var.environment
  application  = var.application
  host_names    = ["cpr-stage.maderenovations.com"]
  path_patterns = ["/graphql"]

  // Container Variables
  application_type   = "backend"
  launch_type        = "EC2"
  container_image    = "nginx-helloworld:latest"
  desired_count      = 1
  container_port     = 4000
  container_memory   = 256
  container_cpu      = 256
  health_check_path  = "/graphql"
  container_env_vars = {
    "foo": "bar"
  }

}