output "arn" {
  value = aws_ecr_repository.this.arn
  description = "ARN of the created ECR repository"
}

output "repository_url" {
    value = aws_ecr_repository.this.repository_url
    description = "URL of the docker repository repo"
}