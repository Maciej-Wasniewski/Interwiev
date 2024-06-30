### Bucket for state file. Created before adding entries in the version.tf file. Otherwise we will get an error: Failed to get existing workspaces: S3 bucket does not exist
resource "aws_s3_bucket" "state_files_bucket" {
  bucket = var.state_file_bucket_name

  tags = {
    Name        = var.state_file_bucket_name
    ProjectName = var.project_name
  }
}

resource "aws_s3_bucket_ownership_controls" "state_files_bucket" {
  bucket = aws_s3_bucket.state_files_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "state_files_bucket" {
  bucket = aws_s3_bucket.state_files_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

### Dynamodb table for session locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = var.project_name
  }
}

### Security group for RDS. I open the network traffic completely for the purpose of exercising. Normally this is not a good practice

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow inbound PostgreSQL traffic"
  vpc_id      = data.aws_vpc.vps_rds.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Secret for RDS database
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "interview_secret_for_rds" {
  name = "interview-secret-for-rds"
}

resource "aws_secretsmanager_secret_version" "interview_secret_for_rds" {
  secret_id = aws_secretsmanager_secret.interview_secret_for_rds.id
  secret_string = jsonencode({
    username = var.rds_username
    password = random_password.password.result
  })
}

### RDS database for names and birthdays

data "aws_secretsmanager_secret" "interview_secret_for_rds" {
  name = aws_secretsmanager_secret.interview_secret_for_rds.name
}

data "aws_secretsmanager_secret_version" "interview_secret_for_rds" {
  secret_id = data.aws_secretsmanager_secret.interview_secret_for_rds.id
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.interview_secret_for_rds.secret_string)
}

data "aws_vpc" "vps_rds" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]  
  }
}

data "aws_subnets" "rds_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vps_rds.id]
  }
}

resource "aws_db_subnet_group" "rds_vpc_subnets" {
  name       = "main"
  subnet_ids = data.aws_subnets.rds_vpc_subnets.ids

  tags = {
    Name = "My DB subnet group"
    ProjectName = var.project_name
  }
}

resource "aws_db_instance" "rds_database_interview" {
  identifier           = var.rds_database_name
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15.4"
  username             = local.db_creds.username
  password             = local.db_creds.password
  db_subnet_group_name = aws_db_subnet_group.rds_vpc_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible  = true
  skip_final_snapshot  = true
  multi_az             = false
  storage_encrypted    = true
  
  tags = {
    Name = var.rds_database_name
  }
}

### ECR repository
module "ecr_pytest" {
  source          = "./modules/ecr"
  repository_name = "pytest"
}

module "ecr_fastapi" {
  source          = "./modules/ecr"
  repository_name = "fastapi"
}

module "ecr_streamlit" {
  source          = "./modules/ecr"
  repository_name = "streamlit"
}

### ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  tags = {
    Name        = "${var.project_name}-ecs-cluster"
    ProjectName = var.project_name
  }
}

# Security group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Allow inbound traffic for ECS tasks"
  vpc_id      = data.aws_vpc.vps_rds.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ecs-tasks-sg"
    ProjectName = var.project_name
  }
}

# IAM role dla ECS task execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ecs-execution-role"
    ProjectName = var.project_name
  }
}

# Attach policy to ECS execution role
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-ecs-logs"
    ProjectName = var.project_name
  }
}