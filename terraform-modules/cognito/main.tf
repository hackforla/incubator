resource "aws_cognito_user_pool" "main" {
  name = var.user_pool_name

  // Add additional configurations here based on project needs
}

resource "aws_cognito_user_pool_client" "main" {
  name         = var.client_name
  user_pool_id = aws_cognito_user_pool.main.id

  // Configure client here
  // For example:
  generate_secret                      = false
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  allowed_oauth_flows_user_pool_client = true

  // Other configurations like callback URLs, logout URLs, etc.
}