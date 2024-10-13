
data "aws_iam_user" "appadmin" {
  user_name = "tyler.thome"
}

resource "aws_iam_policy" "homeuniteus_manage_ecr" {
  name        = "ManageHomeUniteUsECR"
  description = "Manage the homeuniteus ECR"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ListImagesInRepository",
        Effect = "Allow",
        Action = [
          "ecr:ListImages"
        ],
        Resource = aws_ecr_repository.this.arn
      },
      {
        "Sid" : "ViewAndUpdateAccessKeys",
        "Effect" : "Allow",
        "Action" : [
          "iam:UpdateAccessKey",
          "iam:CreateAccessKey",
          "iam:ListAccessKeys"
        ],
        "Resource" : data.aws_iam_user.appadmin.arn
      },
      {
        Sid    = "GetAuthorizationToken",
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      },
      {
        Sid    = "ManageRepositoryContents",
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        Resource = aws_ecr_repository.this.arn
      },
      {
        Sid    = "ManageHomeUniteUsCognito",
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        Resource = aws_ecr_repository.this.arn
      },
      {
        Effect = "Allow",
        Action = [
          "cognito-identity:*",
          "cognito-idp:*",
          "cognito-sync:*",
          "iam:ListRoles",
          "iam:ListOpenIdConnectProviders",
          "iam:GetRole",
          "iam:ListSAMLProviders",
          "iam:GetSAMLProvider",
          "kinesis:ListStreams",
          "lambda:GetPolicy",
          "lambda:ListFunctions",
          "sns:GetSMSSandboxAccountStatus",
          "sns:ListPlatformApplications",
          "ses:ListIdentities",
          "ses:GetIdentityVerificationAttributes",
          "mobiletargeting:GetApps",
          "acm:ListCertificates"
        ],
        Resource = aws_cognito_user_pool.homeuniteus.arn
      },
      {
        Effect   = "Allow",
        Action   = "iam:CreateServiceLinkedRole",
        Resource = aws_cognito_user_pool.homeuniteus.arn,
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = [
              "cognito-idp.amazonaws.com",
              "email.cognito-idp.amazonaws.com"
            ]
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "iam:DeleteServiceLinkedRole",
          "iam:GetServiceLinkedRoleDeletionStatus"
        ],
        Resource = [
          "arn:aws:iam::*:role/aws-service-role/cognito-idp.amazonaws.com/AWSServiceRoleForAmazonCognitoIdp*",
          "arn:aws:iam::*:role/aws-service-role/email.cognito-idp.amazonaws.com/AWSServiceRoleForAmazonCognitoIdpEmail*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "cloudshell:CreateEnvironment",
          "cloudshell:GetEnvironmentStatus",
          "cloudshell:CreateSession"
        ],
        Resource = [
          "*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ecs:ExecuteCommand"
        ],
        Resource = [
          "arn:aws:ecs:us-west-2:035866691871:cluster/incubator-prod",
          "arn:aws:ecs:us-west-2:035866691871:task/incubator-prod/*"
        ]
      }
      //arn:aws:cloudshell:us-west-2:035866691871:environment/642f2b30-d2dd-4fc6-95ad-3e32b4163d23
      # ,
      # {
      #   Sid = "ShellEcsContainerTask",
      #   Effect = "Allow",
      #   Action = [
      #     "ecs:ExecuteCommand",
      #   ],
      #   Resource =  "arn:aws:ecs:us-west-2:035866691871:cluster/incubator-prod"
      # },
      # {
      #   Sid = "ShellEcsContainer",
      #   Effect = "Allow",
      #   Action = [
      #     "ecs:ExecuteCommand",
      #   ],
      #   Resource =  "arn:aws:ecs:us-west-2:035866691871:task/incubator-prod/48f95a3b35de4198a637827d6b020c37"
      # }
    ]
  })
}

# Attaching a policy to the role
resource "aws_iam_user_policy_attachment" "homeuniteus_manage_ecr_tyler" {
  user       = data.aws_iam_user.appadmin.user_name
  policy_arn = aws_iam_policy.homeuniteus_manage_ecr.arn
}

# Attaching a policy to the role
resource "aws_iam_user_policy_attachment" "homeuniteus_cloudshell_admin" {
  user       = data.aws_iam_user.appadmin.user_name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudShellFullAccess"
}

//arn:aws:iam::aws:policy/AWSCloudShellFullAccess