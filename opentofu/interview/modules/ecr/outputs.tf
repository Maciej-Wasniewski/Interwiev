output "repository_url" {
  value       = aws_ecr_repository.repo.repository_url
  description = "URL ECR repository"
}

output "repository_arn" {
  value       = aws_ecr_repository.repo.arn
  description = "ARN repository ECR"
}