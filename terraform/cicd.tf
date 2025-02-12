// define IAM policy used by GitHub actions


resource "aws_iam_policy" "incubator_builder" {
  name        = "incubator_builder"
  path        = "/"
  description = "Policy that projects on incubator use in their cicd pipelines"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      // allow push to ECR
      {
        Sid = "EcrPush"
        Effect = "Allow"
        Action = [
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
           "ecr:InitiateLayerUpload",
           "ecr:BatchCheckLayerAvailability",
           "ecr:PutImage",
           "ecr:BatchGetImage"
        ]
        Resource = "arn:aws:ecr:us-west-2:${data.aws_caller_identity.current.account_id}:repository/*"
      },
      {
        Sid = "EcrAuthToken"
        Effect = "Allow"
        Action = "ecr:GetAuthorizationToken",
        Resource = "*"
      },
      // allow restart service
      {
         Sid = "DeployService"
         Effect = "Allow"
         Action = [
            "ecs:UpdateService",
            "ecs:DescribeServices"
         ]
         Resource  = [
            "arn:aws:ecs:us-west-2:${data.aws_caller_identity.current.account_id}:service/incubator-prod/*"
         ]
      }
    ]
  })
}