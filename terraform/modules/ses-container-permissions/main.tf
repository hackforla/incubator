/**
 * # ses-container-permissions
 *
 * Lets one container send email through specific SES identities using its task role, so the
 * application needs no access keys. It creates a managed IAM policy allowing
 * `ses:SendEmail` and `ses:SendRawEmail` on the given identity ARNs only, and attaches it to
 * the task role.
 *
 * SES authorizes a send against the identity of the **From** address. A container sending as
 * `someone@example.org` needs that address's identity, or its domain's, in `identity_arns`.
 * A domain identity covers every address at that domain. A send from any other address is
 * denied, even if the account has verified that address.
 *
 * For the task role to be used, the application must create its SES client with the AWS
 * SDK's default credential chain. If it passes access keys explicitly, it keeps using those
 * keys and this policy has no effect.
 *
 * The policy grants no configuration sets. An application that names one in its send
 * request needs that configuration set's ARN allowed as well.
 *
 * Usage, with the identity created by the `ses` module:
 *
 * ```hcl
 * module "prod_ses_send" {
 *   source         = "../../modules/ses-container-permissions"
 *   name           = "food-oasis-prod-ses-send"
 *   task_role_name = module.prod_service.task_role_name
 *   identity_arns  = [module.ses_foodoasis_net.arn]
 *   tags           = { project = local.project_name_food_oasis }
 * }
 * ```
 */

resource "aws_iam_policy" "this" {
  name        = var.name
  description = "Send email through specific SES identities"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "SendFromIdentities"
        Effect   = "Allow"
        Action   = ["ses:SendEmail", "ses:SendRawEmail"]
        Resource = var.identity_arns
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = var.task_role_name
  policy_arn = aws_iam_policy.this.arn
}
