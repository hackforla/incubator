output "ecr_repository_url" {
  value       = module.food_oasis_ecr_fullstack.repository_url
  description = "URL of the image repository both environments pull from"
}

output "place_index_names" {
  value       = { for env, index in aws_location_place_index.this : env => index.index_name }
  description = "Amazon Location place index name per environment, for the service's PLACE_INDEX_NAME"
}

output "location_search_policy_arns" {
  value       = { for env, policy in aws_iam_policy.location_search : env => policy.arn }
  description = "IAM policy per environment allowing address search on that environment's place index, for the service's task role"
}

output "cicd_role_arn" {
  value       = module.food_oasis_cicd.role_arn
  description = "IAM role GitHub Actions in hackforla/food-oasis assumes to push images and redeploy services"
}

output "ses_identity_arn" {
  value       = module.ses_foodoasis_net.arn
  description = "SES identity for foodoasis.net, for each service's ses-container-permissions identity_arns"
}
