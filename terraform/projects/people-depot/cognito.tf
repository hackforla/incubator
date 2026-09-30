// people-depot's app clients in the shared Cognito user pool, adopted in place. See
// hackforla/incubator#17.
//
// The client names are long descriptions rather than names, and they are kept as-is:
// they are what Cognito shows, and changing them is a live change for no benefit.
module "shared_user_pool_access" {
  source = "../../modules/shared-user-pool-access"

  user_pool_id  = var.shared_user_pool_id
  user_pool_arn = var.shared_user_pool_arn

  // Grants the dev backend's task role admin operations on the shared pool. Note this
  // covers every user in the pool, not only people-depot's.
  task_role_name = module.backend_dev_service.task_role_name

  clients = {
    peopledepot = {
      name                                 = "PEOPLEDEPOT is a backend app client that contains a secret"
      generate_secret                      = true
      supported_identity_providers         = ["COGNITO"]
      callback_urls                        = ["http://localhost:8000/accounts/amazon-cognito/login/callback/", "http://localhost:8000/admin/"]
      allowed_oauth_flows                  = ["code"]
      allowed_oauth_scopes                 = ["email", "openid", "profile"]
      allowed_oauth_flows_user_pool_client = true
    }
    pd-2 = {
      name                                 = "pd-2 is a secret-less app client which should be used with a frontend and NOT with a backend"
      supported_identity_providers         = ["COGNITO"]
      callback_urls                        = ["http://localhost:8000/accounts/amazon-cognito/login/callback/", "http://localhost:8000/admin/"]
      allowed_oauth_flows                  = ["code"]
      allowed_oauth_scopes                 = ["email", "openid", "profile"]
      allowed_oauth_flows_user_pool_client = true
    }
    backend = {
      name                                 = "backend is the old app client used by PD, which returns the auth token in the url"
      generate_secret                      = true
      explicit_auth_flows                  = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
      supported_identity_providers         = ["COGNITO"]
      callback_urls                        = ["http://localhost:8000/admin"]
      allowed_oauth_flows                  = ["implicit"]
      allowed_oauth_scopes                 = ["openid"]
      allowed_oauth_flows_user_pool_client = true
    }
  }
}
