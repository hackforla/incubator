/**
 * # shared-user-pool-access
 *
 * Gives one project access to the shared Cognito user pool declared in
 * `terraform/cognito.tf`: the project's own app clients in that pool and, optionally,
 * admin rights on the pool for the project's task role. See hackforla/incubator#17.
 *
 * Every client in the pool shares the pool's users, so a project that wants users of its
 * own should declare its own pool instead, as home-unite-us does.
 *
 * ## Admin rights
 *
 * Set `task_role_name` to grant the role the four Cognito operations that need IAM --
 * `AdminGetUser`, `AdminCreateUser`, `AdminAddUserToGroup` and `AdminDeleteUser` -- on the
 * shared pool only. These are the same four the container module already grants on pools
 * tagged with the project's name; the shared pool carries no `project` tag, so this module
 * is the only way a project gets them there. Leave it unset for a project that only signs
 * users in: those APIs authorize against the end user's own credentials and need no IAM.
 *
 * Note that the pool is shared, so these rights cover every project's users in it, not
 * just this project's.
 *
 * ## Client secrets
 *
 * `generate_secret` cannot be read back from the API, so an imported client plans a
 * replacement unless it is ignored -- and replacing a client mints a new client id, which
 * breaks any application configured with the old one. The module therefore ignores it,
 * and prevents destroy so any future replacement fails loudly instead.
 */

locals {
  // Every client in the pool reads and writes the full set of standard attributes, bar
  // the two verification flags, which are read-only.
  write_attributes = [
    "address",
    "birthdate",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]
  read_attributes = concat(local.write_attributes, ["email_verified", "phone_number_verified"])
}

resource "aws_cognito_user_pool_client" "this" {
  for_each = var.clients

  name         = each.value.name
  user_pool_id = var.user_pool_id

  generate_secret                      = each.value.generate_secret
  explicit_auth_flows                  = each.value.explicit_auth_flows
  supported_identity_providers         = each.value.supported_identity_providers
  callback_urls                        = each.value.callback_urls
  allowed_oauth_flows                  = each.value.allowed_oauth_flows
  allowed_oauth_scopes                 = each.value.allowed_oauth_scopes
  allowed_oauth_flows_user_pool_client = each.value.allowed_oauth_flows_user_pool_client

  read_attributes  = local.read_attributes
  write_attributes = local.write_attributes

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30
  auth_session_validity  = 3

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  prevent_user_existence_errors                 = "ENABLED"
  enable_token_revocation                       = true
  enable_propagate_additional_user_context_data = false

  lifecycle {
    ignore_changes  = [generate_secret]
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy" "admin" {
  count = var.task_role_name == null ? 0 : 1

  name = "shared-user-pool-admin"
  role = var.task_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SharedUserPoolAdmin"
        Effect = "Allow"
        Action = [
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminAddUserToGroup",
          "cognito-idp:AdminDeleteUser",
        ]
        Resource = var.user_pool_arn
      },
    ]
  })
}
