output "bucket_name" {
  description = "Bucket name for state files"
  value       = aws_s3_bucket.state_files_bucket.id
}

output "bucket_arn" {
  description = "ARN bucket for state files"
  value       = aws_s3_bucket.state_files_bucket.arn
}

output "secret_name" {
  description = "Secret name for rds database"
  value       = aws_secretsmanager_secret.interview_secret_for_rds.name
}

output "db_endpoint" {
  description = "The endpoint of the database"
  value       = aws_db_instance.rds_database_interview.endpoint
}

output "used_subnet_ids" {
  description = "IDs of subnets used for the RDS instance"
  value       = data.aws_subnets.rds_vpc_subnets.ids
}
