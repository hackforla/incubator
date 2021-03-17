locals {
  asg_tags = [
    for k, v in merge(var.tags, { Name = "bastion-${local.envname}" }) : {
      "key" = k
      "value" = v
      "propagate_at_launch" = true
    }
  ]
}
resource "aws_launch_configuration" "bastion" {
  name       = "${local.envname}-bastion"
  image_id          = data.aws_ami.ami.id
  instance_type     = var.bastion_instance_type
  user_data         = local.template_file_init
  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  
  security_groups = [aws_security_group.bastion.id]

  associate_public_ip_address = true
  key_name                    = var.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion" {
  name = aws_launch_configuration.bastion.name

  vpc_zone_identifier = var.public_subnet_ids

  desired_capacity          = "1"
  min_size                  = "0"
  max_size                  = "1"
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = aws_launch_configuration.bastion.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tags = local.asg_tags

  lifecycle {
    create_before_destroy = true
  }
}