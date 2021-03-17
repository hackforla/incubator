resource "aws_iam_user" "gha_user" {
  name = "github-action-incubator"

  tags = var.tags
}


resource "aws_iam_access_key" "gha_keys" {
  user = aws_iam_user.gha_user.name
}

resource "aws_iam_user_policy" "gha_policy" {
  name = "github_action_policy"
  user = aws_iam_user.gha_user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws:iam::${var.account_id}:role/ecsServiceRole",
                "arn:aws:iam::${var.account_id}:role/ecsTaskExecutionRole",
                "${var.execution_role_arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecs:RegisterTaskDefinition",
                "ecs:DescribeTaskDefinition",
                "ecs:UpdateService",
                "ecs:DescribeServices",
                "ecr:CompleteLayerUpload",
                "ecr:GetAuthorizationToken",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:ListImages",
                "ecr:CreateRepository"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:UpdateAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

output "access_key_id" {
  value = aws_iam_access_key.gha_keys.id
}

output "secret_access_key_id" {
  value = aws_iam_access_key.gha_keys.secret
}
