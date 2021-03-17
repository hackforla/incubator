#----- ECS --------
resource "aws_ecs_cluster" "cluster" {
  name = local.envname

  capacity_providers = ["FARGATE", aws_ecs_capacity_provider.prov1.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.prov1.name
    weight            = 100
  }

  tags = var.tags
}

resource "aws_ecs_capacity_provider" "prov1" {
  name = "prov1"

  auto_scaling_group_provider {
    auto_scaling_group_arn = module.asg.this_autoscaling_group_arn
  }

  tags = var.tags
}

#----- ECS  Resources--------
data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = local.envname

  # Launch configuration
  lc_name = local.envname

  image_id             = data.aws_ami.amazon_linux_ecs.id
  key_name             = var.key_name
  instance_type        = var.ecs_ec2_instance_type
  security_groups      = [aws_security_group.ecs_instance.id]
  iam_instance_profile = "ecsInstanceRole"
  user_data            = data.template_file.user_data.rendered

  # Auto scaling group
  asg_name                  = local.envname
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

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.sh")

  vars = {
    cluster_name = local.envname
  }
}

resource "aws_security_group" "ecs_instance" {
  name        = "ecs_container_instance_${local.envname}"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "All ingress from ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    description = "All Internal traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ecs_container_instance_${local.envname}" }
}
