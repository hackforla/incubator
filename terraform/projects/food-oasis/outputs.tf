output "ecr_repository_url" {
  value       = module.food_oasis_ecr_fullstack.repository_url
  description = "URL of the image repository both environments pull from"
}

output "cicd_role_arn" {
  value       = module.food_oasis_cicd.role_arn
  description = "IAM role GitHub Actions in hackforla/food-oasis assumes to push images and redeploy services"
}
