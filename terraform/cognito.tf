# The shared Cognito user pool, for Hack for LA apps whose users are HfLA volunteers
# rather than each app's own external users. Projects get access to it through
# modules/shared-user-pool-access, which gives each one its own app clients and,
# optionally, admin rights for its task role. See hackforla/incubator#17.
#
# Adopted in place from the pool that was created by hand in 2022 as `vrms-dev`. Despite
# the name it is not specific to VRMS: three of its four app clients belong to
# people-depot, which is also the only project whose running container points at it.
# The name stays because renaming a Cognito user pool replaces it, which would destroy
# its user accounts.
#
# Deliberately carries no `project` tag. It belongs to no single project, and the
# container module grants Cognito admin rights on pools tagged with a project's name, so
# a tag here would hand that project admin rights over every other project's users.
# Access is granted explicitly by modules/shared-user-pool-access instead.
#
# Every value below is written to match live AWS, so that the plan after the imports in
# import.tf reports no changes apart from the provider's default tags.
resource "aws_cognito_user_pool" "shared" {
  name = "vrms-dev"

  // The pool predates Cognito's tier feature and is on LITE. The provider defaults this
  // attribute to ESSENTIALS, so omitting it would plan a billing upgrade.
  user_pool_tier = "LITE"

  mfa_configuration        = "OFF"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  deletion_protection      = "INACTIVE"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  username_configuration {
    case_sensitive = false
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  // Destroying this pool destroys every user account in it, which recreating it cannot
  // bring back.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_cognito_user_pool_domain" "shared" {
  domain       = "hackforla-vrms-dev"
  user_pool_id = aws_cognito_user_pool.shared.id
}
