resource "aws_ecs_cluster" "this" {
  name = "incubator-prod"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  # Ten services run here; a replacement would stop all of them.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ecs_capacity_provider" "ec2" {
  name = "incubator-proc-ec2" # typo is live; renaming forces a replacement

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"
    managed_draining               = "DISABLED"

    # Off, but AWS returns these values regardless, so omitting the block shows as a diff.
    managed_scaling {
      status                    = "DISABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 10000
      instance_warmup_period    = 300
    }
  }
}

# Its own resource rather than an attribute of the cluster. FARGATE_SPOT exists in the
# account but is not attached here, and adding it would be a live change.
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE", aws_ecs_capacity_provider.ec2.name]
}

resource "aws_launch_template" "ecs" {
  name          = "ecs-incubator-prod"
  image_id      = "ami-036428f37186903ce"
  instance_type = "m5.large"
  key_name      = "ecs-incubator-prod"

  # The VPC default group, not a purpose-built one. The group that looked like the container
  # instances' own turned out to be attached to nothing and was deleted in #184.
  vpc_security_group_ids = [aws_default_security_group.this.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_instance.arn
  }

  # Enables awsvpcTrunking, installs the SSM agent, sets ECS_CLUSTER. Kept as literal base64
  # because version 8 has a trailing space a heredoc would drop, minting a version 9.
  user_data = "IyEvYmluL2Jhc2gKYXdzIGVjcyBwdXQtYWNjb3VudC1zZXR0aW5nIC0tbmFtZSBhd3N2cGNUcnVua2luZyAtLXZhbHVlIGVuYWJsZWQgLS1yZWdpb24gdXMtd2VzdC0yIApjZCAvdG1wCnN1ZG8gZG5mIGluc3RhbGwgLXkgaHR0cHM6Ly9zMy5hbWF6b25hd3MuY29tL2VjMi1kb3dubG9hZHMtd2luZG93cy9TU01BZ2VudC9sYXRlc3QvbGludXhfYW1kNjQvYW1hem9uLXNzbS1hZ2VudC5ycG0Kc3VkbyBzeXN0ZW1jdGwgZW5hYmxlIGFtYXpvbi1zc20tYWdlbnQKc3VkbyBzeXN0ZW1jdGwgc3RhcnQgYW1hem9uLXNzbS1hZ2VudAplY2hvICJFQ1NfQ0xVU1RFUj1pbmN1YmF0b3ItcHJvZCIgPj4gL2V0Yy9lY3MvZWNzLmNvbmZpZwo="

  default_version = 1 # live default is 1 even though version 8 is what runs
}

resource "aws_autoscaling_group" "ecs" {
  name                      = "ecs-incubator-prod"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 2
  default_cooldown          = 300
  health_check_type         = "EC2"
  health_check_grace_period = 300
  termination_policies      = ["Default"]
  protect_from_scale_in     = false
  vpc_zone_identifier       = [for s in aws_subnet.private : s.id]

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  # Load-bearing: this tag is how the capacity provider recognises the group.
  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  # ECS drains and replaces instances through the capacity provider; do not fight it.
  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
