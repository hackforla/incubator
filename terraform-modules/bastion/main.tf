locals {
  // selects a randoms public subnet to create the bastion in
  subnet_id = element(var.public_subnet_ids, 1)

  template_file_init = templatefile("${path.module}/user_data.sh", {
    domain_name = var.domain_name
    bastion_hostname = var.bastion_hostname
    ssh_user                    = var.ssh_user,
    github_repo_owner           = var.bastion_github_file.github_repo_owner,
    github_repo_name            = var.bastion_github_file.github_repo_name,
    github_branch               = var.bastion_github_file.github_branch,
    github_filepath             = var.bastion_github_file.github_filepath,
    cron_key_update_schedule    = var.cron_key_update_schedule,
    enable_hourly_cron_updates  = var.enable_hourly_cron_updates,
    additional_user_data_script = var.additional_user_data_script
  })
}

// Pull latest Ubuntu AMI
// TODO: Find publicly available hardened ubuntu AMI
data "aws_ami" "ami" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
