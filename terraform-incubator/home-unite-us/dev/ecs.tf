data "aws_iam_role" "ecs_task" {
  name = "incubator-prod-ecs-task-role"
}

resource "aws_iam_policy" "ecs_shell_dev" {
  name        = "HomeUniteUsECSExecDev"
  description = "Execute shell commands on dev HUU containers"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      }
    ]
  })
}


# enables:
#  aws ecs execute-command --cluster incubator-prod --container homeuniteus --task bea9b5813b5f42db8191b723ab9e6d9c --command /bin/bash --interactive
resource "aws_iam_role_policy_attachment" "ecs_shell_dev" {
  role       = data.aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_shell_dev.arn
}

# aws_ecs_task_definition.task:
resource "aws_ecs_task_definition" "homeuniteus" {
  container_definitions = jsonencode(
    [
      {
        cpu = 256
        environment = [{
          "name"  = "APP_ENVIRONMENT",
          "value" = "DEV"
        }]
        essential = true
        image     = "035866691871.dkr.ecr.us-west-2.amazonaws.com/homeuniteus:20241017.1"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "ecs/homeuniteus"
            awslogs-region        = "us-west-2"
            awslogs-stream-prefix = "app"
          }
        }
        memoryReservation = 512
        mountPoints       = []
        name              = "homeuniteus"
        portMappings = [
          {
            containerPort = 80
            protocol      = "tcp"
          },
        ]
        readonlyRootFilesystem = false
        volumesFrom            = [],
        initProcessEnabled     = true
      },
    ]
  )
  cpu                = "256"
  execution_role_arn = data.aws_iam_role.ecs_task.arn
  family             = "homeuniteus"
  memory             = "512"
  network_mode       = "awsvpc"

  requires_compatibilities = [
    "FARGATE",
  ]
  task_role_arn = data.aws_iam_role.ecs_task.arn
}

resource "aws_security_group" "homeuniteus" {
  name        = "ecs_fargate_${local.app_name}"
  description = "Allow TLS inbound traffic"
  vpc_id      = local.vpc_id

  ingress {
    description = "All Internal traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.incubator.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ecs_container_instance_${local.app_name}" }
}

resource "aws_ecs_service" "homeuniteus" {
  name                   = "homeuniteus"
  cluster                = "arn:aws:ecs:us-west-2:035866691871:cluster/incubator-prod"
  enable_execute_command = true
  task_definition        = aws_ecs_task_definition.homeuniteus.arn
  launch_type            = "FARGATE"
  desired_count          = 1

  network_configuration {
    subnets = [
      "subnet-03202f3bf9a24c1a5",
      "subnet-08c26edd1afc2b9d7",
    ]
    security_groups  = [aws_security_group.homeuniteus.id]
    assign_public_ip = true
  }

  load_balancer {
    container_name   = local.app_name
    container_port   = 80
    target_group_arn = aws_lb_target_group.homeuniteus.arn
  }

  depends_on = [aws_lb_target_group.homeuniteus, aws_lb_listener_rule.homeuniteus]

  lifecycle {
    ignore_changes = [desired_count]
  }
}