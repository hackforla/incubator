/**
 * # container
 *
 * This module sets up a running container within ECS. This could be a backend, frontend,
 * or fullstack container
 * 
 * Some things to watch out for:
 * 1. `listener_priority` - determines the order that load balancer rules run in when
 * forwarding traffic to the service. If you have a backend that runs with the path `/api/v1`,
 * and a frontend that just runs with `/`, make sure that the backend has a lower listener
 * priority than the frontend, otherwise all traffic will be sent to the frontend.
 *
 * ## How the target group name is built
 *
 * An ELB target group name cannot exceed 32 characters. That limit is verified against
 * live AWS rather than assumed: `describe-target-groups` accepts a 32-character name and
 * returns `TargetGroupNotFound`, and rejects a 33-character one with
 * `ValidationError: Target group name ... cannot be longer than '32' characters`.
 *
 * `name_prefix` on `aws_lb_target_group` is not an alternative -- the provider rejects it
 * above 6 characters, which is far too short to carry a project, an application type and
 * an environment.
 *
 * So the module derives the name itself, from a ladder of candidates. The first one that
 * fits in 32 characters wins:
 *
 * 1. `<project>-<application_type>-<environment>-<hash>` -- the full, readable name. Every
 *    target group in the account uses this today except civic-tech-index's and
 *    civic-tech-jobs', which fall to rung 2.
 * 2. `<initials>-<abbr>-<environment>-<hash>` -- the project reduced to the initials of its
 *    hyphen-separated words and the application type to two letters. These are abbreviated
 *    *together*, rather than trying the application type alone first, so that a name which
 *    overflows drops to something obviously abbreviated instead of a near-miss that still
 *    reads like the full name.
 * 3. `<initials, 14 max>-<md5 of the full name, 8>-<hash>` -- at most 27 characters, so it
 *    always fits. This exists for a single-word project name too long for rung 2, and is
 *    unreachable in practice. Do not drop it because no current project reaches it: without
 *    it, such a name fails at apply with an AWS `ValidationError` instead of producing a
 *    legal, deterministic name.
 *
 * Rung 3 carries two independent hashes, which looks redundant and is not. They hash
 * different things for different reasons: `md5` of the full name distinguishes two projects
 * whose initials collide, and `local.tg_suffix` changes whenever an attribute forces the
 * target group to be replaced.
 *
 * Rungs 1 and 2 have no such collision resistance -- two projects whose initials, abbreviated
 * application type and environment all coincide would produce the same rung-2 name, and the
 * ladder does not detect that. No current pair collides. If one ever does, AWS refuses the
 * duplicate at apply time.
 *
 * Only the target group name is abbreviated. `local.envappname` still spells the application
 * type out in full, because it names the ECS service, task-definition family, log group,
 * security group and IAM role, none of which is length-constrained.
 */

// terraform-docs-ignore


locals {
  envappname = "${var.project_name}-${var.application_type}-${var.environment}"

  # Conditionals for container compute resources
  # 0 CPU means unlimited cpu access
  # 0 memory is invalid, thus it defaults to 128mb
  container_cpu    = var.container_cpu 
  container_memory = var.container_memory

  # EC2 deliberately omits task-level cpu/memory. Task-level memory is a hard cap AND is
  # what the scheduler subtracts from a host, so setting it would override the soft
  # container-level memoryReservation below and undo the packing. Fargate requires both.
  task_cpu    = local.is_fargate ? var.container_cpu : null
  task_memory = local.is_fargate ? var.container_memory : null

  is_fargate = var.launch_type == "fargate"

  # prod must keep a task serving throughout a deploy, so it always needs a spare ENI
  # slot. Non-prod may drop to zero, which lets a deploy proceed even when the cluster
  # has no free slot left.
  deployment_min = var.deployment_minimum_healthy_percent != null ? var.deployment_minimum_healthy_percent : (var.environment == "prod" ? 100 : 0)
  # max stays 200 everywhere: ECS Availability Zone Rebalancing rejects maximumPercent <= 100,
  # so a non-prod 0/100 is refused at UpdateService. 0/200 still lets a deploy fall back to
  # stop-then-start when no spare ENI slot is free, rather than deadlocking on placement.
  deployment_max = var.deployment_maximum_percent != null ? var.deployment_maximum_percent : 200

  # ENI slots (10 per m5.large) are the scarce resource and ECS cannot binpack on ENIs,
  # so spread -- binpacking memory would fill one host's slots while the other sat idle.
  placement_strategies = local.is_fargate ? [] : [
    { type = "spread", field = "attribute:ecs.availability-zone" },
    { type = "spread", field = "instanceId" },
  ]

  task_network_mode = "awsvpc"

  # vpc_id, tg_protocol and target_type are referenced both by the resources below and by
  # tg_suffix, so they live here to keep the two from drifting apart.
  vpc_id      = "vpc-0bec93a4d80243845"
  tg_protocol = "HTTP"
  target_type = "ip"

  # A target group name is capped at 32 characters and name_prefix is rejected above 6, so
  # neither Terraform's own prefix mechanism nor a longer suffix fits. This is a 3-character
  # hash of exactly the attributes that force a replacement, so anything that replaces the
  # target group also changes its name -- which is what lets create_before_destroy stand the
  # new group up beside the old one instead of failing with DuplicateTargetGroupName.
  #
  # KEEP IN SYNC: every ForceNew attribute this module sets on aws_lb_target_group must
  # appear in this list. Adding one without adding it here silently reintroduces the
  # duplicate-name failure. Three characters is the maximum that fits --
  # home-unite-us-fullstack-prod-596 is exactly 32.
  tg_suffix = substr(sha1(jsonencode([var.container_port, local.tg_protocol, local.target_type, local.vpc_id])), 0, 3)

  # Initials of the project: the first letter of each hyphen-separated word, so
  # civic-tech-index -> cti and home-unite-us -> huu. A single-word name has no initials
  # worth taking -- vrms would become "v" -- so it is returned whole instead.
  tg_initials = length(split("-", var.project_name)) > 1 ? join("", [for w in split("-", var.project_name) : substr(w, 0, 1)]) : var.project_name

  # The input is its own default, so an application_type not listed here passes through
  # unchanged rather than disappearing.
  tg_app_abbr = lookup({ fullstack = "fs", backend = "be", frontend = "fe" }, var.application_type, var.application_type)

  # See the header comment for what each rung is for. tg_name takes the first that fits.
  # Rung 3 is at most 27 characters, so the list is never empty and the index never fails.
  tg_candidates = [
    "${var.project_name}-${var.application_type}-${var.environment}-${local.tg_suffix}",
    "${local.tg_initials}-${local.tg_app_abbr}-${var.environment}-${local.tg_suffix}",
    "${substr(local.tg_initials, 0, 14)}-${substr(md5(local.envappname), 0, 8)}-${local.tg_suffix}",
  ]

  tg_name = [for c in local.tg_candidates : c if length(c) <= 32][0]

  hostname_array = concat([var.hostname], var.additional_host_urls)
}

// security group for the container
// ingress of the provided port, unlimited egress
resource "aws_security_group" "container" {
  name        = "ecs-container-${local.envappname}"
  description = "Container ${local.envappname}"
  vpc_id      = local.vpc_id

  tags = {
    Name = "ecs-container-${local.envappname}"
  }

  # Create the replacement before destroying the old group: the old one cannot be deleted
  # while a draining task's ENI is still attached, which surfaces as DependencyViolation.
  # Creating first gives the service somewhere to move to before the old group goes away.
  #
  # Known limitation: this works for a *rename*, where the old and new names differ. A
  # replacement forced by something that leaves the name alone -- description or vpc_id --
  # would try to create a second group with the same name and fail on InvalidGroup.Duplicate.
  # There is no hash suffix here, unlike the target group below, because a security group
  # name has no 32-character cap and nothing reads it.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "container_ingress_port" {
  security_group_id = aws_security_group.container.id
  cidr_ipv4         = "10.10.0.0/16"
  from_port         = var.container_port
  ip_protocol       = "tcp"
  to_port           = var.container_port

  # security_group_id is ForceNew, so this rule is replaced whenever the group above is.
  # Without this it would plan -/+ against the group's +/-, tearing the ingress rule down
  # while the old tasks are still serving.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.container.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports

  # Replaced with the group above, for the same reason as the ingress rule.
  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_lb_target_group" "this" {
  name                 = local.tg_name
  port                 = var.container_port
  deregistration_delay = 10
  protocol             = local.tg_protocol
  target_type          = local.target_type
  vpc_id               = local.vpc_id

  target_health_state {
    enable_unhealthy_connection_termination = false
  }

  health_check {
    matcher = "200,400,404"
    path    = var.health_check_path == "" ? "" : var.health_check_path
  }

  # Create the replacement before destroying the old group. DeleteTargetGroup fails with
  # ResourceInUse while any listener rule still forwards to it, and aws_lb_listener_rule
  # below is only ever an in-place update -- so the default destroy-then-create order fails
  # half-way through. This is what makes renaming anything in this module safe.
  #
  # It relies on local.tg_suffix above to guarantee the new name differs from the old.
  lifecycle {
    create_before_destroy = true

    # The ladder's last rung always fits, so this cannot fire today. It is here so that a
    # future edit to local.tg_candidates fails at plan time with a readable message naming
    # the inputs, rather than at apply time with an AWS ValidationError.
    precondition {
      condition     = length(local.tg_name) <= 32
      error_message = "No target group name candidate fits in 32 characters for project_name=\"${var.project_name}\", application_type=\"${var.application_type}\", environment=\"${var.environment}\"."
    }
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = "arn:aws:elasticloadbalancing:us-west-2:035866691871:listener/app/incubator-prod-lb/7451adf77133ef36/390a225766a4daf3"
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  depends_on = [ aws_lb_target_group.this ]

  condition {
    path_pattern {
      values = [var.path]
    }
  }

  condition {
    host_header {
      values = local.hostname_array
    }
  }
}


// IAM role for the container
resource "aws_iam_role" "instance" {
  name        = "ecs-container-${local.envappname}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    project = var.project_name
  }
}

resource "aws_iam_policy" "container_policy" {
  name        = "${var.project_name}-${var.application_type}-${var.environment}-task-policy"
  description = ""
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
resource "aws_iam_role_policy_attachment" "task_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.container_policy.arn
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${local.envappname}"

  tags = {
    project = var.project_name
  }
}

// Execution role for the container -- what the ECS agent uses to start the task: pull the
// image, write to the log group and read the secrets in `container_environment_secrets`.
// Distinct from aws_iam_role.instance above, which is what the running application uses.
//
// Naming trap: the shared role this replaces is *named* incubator-prod-ecs-task-role but is
// an execution role. See hackforla/incubator#201.
resource "aws_iam_role" "execution" {
  name = "ecs-execution-${local.envappname}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    project = var.project_name
  }
}

// A project-scoped replacement for AmazonECSTaskExecutionRolePolicy, plus SSM read.
//
// ECR is scoped by the repository's project tag rather than by name, because repository
// names do not follow the project name (home-unite-us's production repository is
// `homeuniteus`). SSM is scoped by path instead: modules/secret names every parameter
// `/<project>/...`, and the trailing slash makes that an exact match that does not depend
// on tags staying correct. No kms:Decrypt is granted -- parameters use the AWS-managed
// alias/aws/ssm key, whose key policy already allows decryption through SSM.
resource "aws_iam_policy" "execution_policy" {
  name        = "${local.envappname}-execution-policy"
  description = "ECS execution role for ${local.envappname}: image pull, logs and secrets, scoped to project ${var.project_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Cannot be scoped to a resource. The token grants nothing by itself.
        Sid      = "EcrAuth"
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid    = "EcrPullProjectImages"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
        ]
        Resource = "arn:aws:ecr:us-west-2:035866691871:repository/*"
        Condition = {
          StringEquals = { "aws:ResourceTag/project" = var.project_name }
        }
      },
      {
        # Both forms: CreateLogStream authorizes against the log group, PutLogEvents against
        # the log stream beneath it.
        Sid    = "WriteOwnLogGroup"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = [
          aws_cloudwatch_log_group.this.arn,
          "${aws_cloudwatch_log_group.this.arn}:*",
        ]
      },
      {
        Sid      = "ReadProjectParameters"
        Effect   = "Allow"
        Action   = "ssm:GetParameters"
        Resource = "arn:aws:ssm:us-west-2:035866691871:parameter/${var.project_name}/*"
      },
    ]
  })

  tags = {
    project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "execution_policy" {
  role       = aws_iam_role.execution.name
  policy_arn = aws_iam_policy.execution_policy.arn
}

resource "aws_ecs_task_definition" "task" {
  family = local.envappname

  container_definitions = jsonencode([
    merge({
      name  = local.envappname
      image = var.container_image
      # cpu 0 on EC2 reserves nothing. Container cpu maps to Docker CpuShares -- a relative
      # weight, not a cap -- so this changes placement only, never runtime headroom.
      cpu = local.is_fargate ? var.container_cpu : 0
      # memory stays the hard cap; memoryReservation (merged in below) is the soft figure
      # the scheduler actually subtracts from a host.
      memory    = var.container_memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group = aws_cloudwatch_log_group.this.name,
          awslogs-region = "us-west-2",
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = var.container_environment
      secrets = var.container_environment_secrets
      readonlyRootFilesystem = false
      initProcessEnabled     = true
    }, local.is_fargate ? {} : { memoryReservation = var.container_memory_reservation })
  ])

  # use_own_execution_role defaults to true. false falls back to the shared
  # incubator-prod-ecs-task-role, which is to be deleted -- along with the variable -- once
  # nothing uses it. See hackforla/incubator#201.
  requires_compatibilities = [ var.launch_type == "fargate" ? "FARGATE" : "EC2"]
  network_mode             = local.task_network_mode
  task_role_arn            = aws_iam_role.instance.arn
  execution_role_arn       = var.use_own_execution_role ? aws_iam_role.execution.arn : "arn:aws:iam::035866691871:role/incubator-prod-ecs-task-role"
  memory                   = local.task_memory
  cpu                      = local.task_cpu

  tags = {
    project = var.project_name
  }
}


resource "aws_ecs_service" "fargate" {
  count                  = 1
  name                   = local.envappname
  cluster                = "incubator-prod"
  enable_execute_command = true
  task_definition        = aws_ecs_task_definition.task.arn
  launch_type            = var.launch_type == "fargate" ? "FARGATE" : "EC2"
  desired_count          = 1

  deployment_minimum_healthy_percent = local.deployment_min
  deployment_maximum_percent         = local.deployment_max

  dynamic "ordered_placement_strategy" {
    for_each = local.placement_strategies
    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  network_configuration {
    subnets          = ["subnet-089e80a53e1522e28", "subnet-03ed55f60a6c28e72"]
    security_groups  = [aws_security_group.container.id]
  }


  # Deliberately no create_before_destroy here, unlike the target group and security group
  # above. Two services can coexist, but each task consumes an ENI, and the cluster's two
  # m5.large instances already hold 12 ENI attachments for 10 running tasks. Standing a full
  # duplicate service up alongside the original risks exhausting ENI slots, which ECS cannot
  # binpack on. See hackforla/incubator#184.
  lifecycle {
    ignore_changes = [desired_count]
  }

  load_balancer {
    container_name = local.envappname
    container_port = var.container_port
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = {
    project = var.project_name
  }

  # Copy the service's tags -- project included -- onto the tasks it launches.
  # ecs:ExecuteCommand authorizes against the task ARN and supports ecs:ResourceTag, so
  # this is what makes per-project ECS Exec scoping possible later; without it a task
  # carries no project at all. enable_ecs_managed_tags is deliberately left at its default
  # of false: it adds only aws:ecs:clusterName and aws:ecs:serviceName, which duplicate
  # what is already in the ARN, and nothing reads them.
  propagate_tags = "SERVICE"
}
