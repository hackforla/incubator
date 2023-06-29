#----- ECS  Resources--------

locals {
  user_data = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${local.envname} >> /etc/ecs/ecs.config
    echo ECS_ENABLE_AWSLOGS_EXECUTIONROLE_OVERRIDE=true >> /etc/ecs/ecs.config
    start ecs
  EOF
}
output "userdata" {value=local.user_data}
output "userdata64" {value=base64encode(local.user_data)}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
data "aws_ssm_parameter" "ec2-ecs-ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  name = local.envname

  # Launch configuration
  lt_name   = local.envname
  create_lt = true
  use_lt    = true

  image_id                 = data.aws_ssm_parameter.ec2-ecs-ami.value
  key_name                 = var.key_name
  instance_type            = var.ecs_ec2_instance_type
  security_groups          = [aws_security_group.ecs_instance.id]
  iam_instance_profile_arn = aws_iam_instance_profile.ecs-instance.arn
  user_data_base64         = base64encode(local.user_data)



  # Auto scaling group
  vpc_zone_identifier       = var.public_subnet_ids
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 2
  desired_capacity          = var.ecs_ec2_instance_count
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = local.envname
      propagate_at_launch = true
    },
  ]
}

resource "aws_security_group" "ecs_instance" {
  name        = format("ecs_container_instance_%s", local.envname)
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "All Internal traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "All Internal traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    description = "ssh Darren"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["71.202.96.174/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = format("ecs_container_instance_%s", local.envname) }
}
