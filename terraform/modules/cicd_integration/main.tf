data "aws_caller_identity" "current" {}

resource "aws_iam_role" "builder" {
  name = "incubator-cicd-${var.project_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated =  "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:hackforla/${var.repository_name}:ref:refs/heads/*",
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.builder.name
  policy_arn = "arn:aws:iam::035866691871:policy/incubator_builder"
}
