# Neither Terraform repo managed any of this: devops-security covers users, groups, custom
# policies and the GHA OIDC roles only. Both roles were in use the day they were adopted.

# What every ECS container instance runs as, through the instance profile below.
resource "aws_iam_role" "ecs_instance" {
  name        = "ecs-ec2-role"
  description = "Allows EC2 instances to call AWS services on your behalf."

  # SSM as well as EC2, because the user_data installs the SSM agent that makes
  # `aws ecs execute-command` work.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      },
      {
        Effect    = "Allow"
        Principal = { Service = "ssm.amazonaws.com" }
        Action    = "sts:AssumeRole"
      },
    ]
  })
}

# The only instance profile left in the account after the dead-IAM sweep of 2026-08-31.
resource "aws_iam_instance_profile" "ecs_instance" {
  name = "ecs-ec2-role"
  role = aws_iam_role.ecs_instance.name
}

# Customer-managed and itself unmanaged, so adopted alongside the role. Lets the instance
# user_data turn on awsvpcTrunking, which raises the ENI limit per instance.
resource "aws_iam_policy" "ecs_put_account_settings" {
  name = "ecs-put-account-settings"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = [
          "ecs:ListAccountSettings",
          "ecs:PutAccountSettingDefault",
          "ecs:DeleteAccountSetting",
          "ecs:PutAccountSetting",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_put_account_settings" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = aws_iam_policy.ecs_put_account_settings.arn
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ssm_core" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ecs" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Named "task role" but used as the execution role -- it pulls images and writes logs. The
# per-project task roles are separate, made by modules/container.
resource "aws_iam_role" "ecs_task_execution" {
  name        = "incubator-prod-ecs-task-role"
  description = "Allow ECS tasks to access AWS resources"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = ""
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      },
    ]
  })

  tags = {
    # Terragrunt-era, from a state file that no longer exists. Adopted, not believed.
    terraform_managed = "true"
    last_changed      = "Sat 2021-May-08 21:10:10"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_ecs" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Broader than an execution role needs. Adopted as-is; narrowing it is a live change.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_ssm" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
