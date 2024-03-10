resource "aws_cognito_user_pool" "main" {
  name = var.user_pool_name

  // Add additional configurations here
}

resource "aws_cognito_user_pool_client" "main" {
  name         = var.client_name
  user_pool_id = aws_cognito_user_pool.main.id

  // Optional: Specify more detailed configurations here
}
