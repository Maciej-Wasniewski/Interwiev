provider "aws" {
  region = var.aws_region
}

provider "postgresql" {
  host     = aws_db_instance.rds_database_interview.endpoint
  port     = 5432
  database = var.rds_database_name
  username = local.db_creds.username
  password = local.db_creds.password
  sslmode  = "disable"
  superuser = false
}