locals {
  environment = "test"
  domain_name = "foodoasis.net"
  default_alb_url = "www.hackforla.org"

  // Route 53 Records - That will point to the ALB
  host_names = ["fight.foodoasis.net"]
  
  // ECS
  ecs_ec2_instance_count = 0
  ecs_ec2_instance_type = "t3.small"

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