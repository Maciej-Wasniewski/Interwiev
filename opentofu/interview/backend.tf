terraform {
  backend "s3" {
    bucket = "mw-opentofu-state-files-bucket"
    key    = "interview/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "terraform-state-lock"
  }
}