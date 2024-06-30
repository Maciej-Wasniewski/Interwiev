# modules/ecr/variables.tf

variable "repository_name" {
  type        = string
  description = "ECR repository name"
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "Determines whether image tags can be overwritten"
}

variable "scan_on_push" {
  type        = bool
  default     = true
  description = "Whether to scan images when pushing"
}

variable "keep_image_count" {
  type        = number
  default     = 10
  description = "Number of recent images to be retained"
}