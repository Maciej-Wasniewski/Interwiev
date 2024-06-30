variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name. For now only for state file in S3 to dynamicly create prefix for every project"
  type        = string
  default     = "interview"
}

variable "state_file_bucket_name" {
  description = "S3 bucket name for state files"
  type        = string
  default     = "mw-opentofu-state-files-bucket"
}

variable "rds_username" {
  description = "username for rds database"
  type        = string
  default     = "postgres"
}

variable "vpc_name" {
  description = "vpc name"
  type        = string
  default     = "my-vpc"
}

variable "rds_database_name" {
  description = "name for instance rds"
  type        = string
  default     = "interview-database"
}