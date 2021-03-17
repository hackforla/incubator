locals {
  environment = "test"
  domain_name = "foodoasis.net"
  default_alb_url = "www.hackforla.org"

  // ALB
  host_names = ["fight.foodoasis.net"]
  
  // ecs
  ecs_ec2_instance_count = 0
  ecs_ec2_instance_type = "t3.small"
  key_name = "fo-us-west-1-kp"

  // redis - 0 means unrestricted and sets memoryReservation = 85
  redis_container_memory      = 0
  redis_container_cpu         = 0

  // Bastion
  bastion_hostname = "bastion2.foodoasis.net"
  cron_key_update_schedule = "5,0,*,* * * * *"
  
  github_file              = {
    github_repo_owner = "hackforla",
    github_repo_name  = "incubator",
    github_branch     = "main",
    github_filepath   = "bastion_github_users",
  }

  // Global tags
  tags = { terraform_managed = "true", last_changed = formatdate("EEE YYYY-MMM-DD hh:mm:ss", timestamp()) }
}