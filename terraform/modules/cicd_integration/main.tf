/**
 * # cicd-integration
 *
 * This module sets up permissions for GitHub actions to perform actions within
 * AWS, without the use of an IAM access key.
 *
 * Once this module is set up in a project, jobs can use the `aws-actions/configure-aws-credentials`
 * step with `role-to-assume` as `arn:aws:iam::035866691871:role/incubator-cicd-(project name)`
 *
 * The role can push images to, and redeploy, only the ECR repositories and ECS services
 * whose `project` tag matches the project name.
 */

// terraform-docs-ignore
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "builder" {
  name = "incubator-cicd-${var.project_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:hackforla/${var.repository_name}:ref:refs/heads/*",
          }
        }
      }
    ]
  })

  tags = {
    project = var.project_name
  }
}

// ECR and ECS are scoped by the resource's project tag rather than by name, because names
// do not follow the project name (home-unite-us's production repository is `homeuniteus`).
// The project name is interpolated here rather than read from ${aws:PrincipalTag/project},
// so the scope does not depend on the role's own tag staying correct.
resource "aws_iam_policy" "builder" {
  name        = "incubator-cicd-${var.project_name}"
  description = "CI/CD for ${var.project_name}: push images and redeploy services tagged with project ${var.project_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Account-level action: it supports no resource ARN and no condition keys, so it
        # cannot be scoped. The token grants nothing by itself.
        Sid      = "EcrAuthToken"
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid    = "EcrPush"
        Effect = "Allow"
        Action = [
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:BatchGetImage",
        ]
        Resource = "arn:aws:ecr:us-west-2:${data.aws_caller_identity.current.account_id}:repository/*"
        Condition = {
          StringEquals = { "aws:ResourceTag/project" = var.project_name }
        }
      },
      {
        Sid    = "DeployService"
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
        ]
        Resource = "arn:aws:ecs:us-west-2:${data.aws_caller_identity.current.account_id}:service/incubator-prod/*"
        Condition = {
          StringEquals = { "aws:ResourceTag/project" = var.project_name }
        }
      },
    ]
  })

  tags = {
    project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.builder.name
  policy_arn = aws_iam_policy.builder.arn
}
