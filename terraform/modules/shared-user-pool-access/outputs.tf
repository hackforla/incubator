output "client_ids" {
  description = "app client id for each entry in `clients`, keyed the same way"
  value       = { for k, c in aws_cognito_user_pool_client.this : k => c.id }
}
