resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${local.envname}_bastion_profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "${local.envname}_bastion_role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "bastion" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_policy" "policy" {
  name        = "${local.envname}_bastion_policy"
  description = "Enable bastion servers to update DNS with bastion hostname"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Sid = "",
            Effect = "Allow",
            Action = [
                "route53:ListHostedZones",
                "route53:ChangeResourceRecordSets"
            ],
            Resource = "*"
        }
    ]
  })
}