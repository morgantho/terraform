variable "aws_profile" {
  description = "Terraform profile"
}

variable "aws_region" {
  description = "us-east-2"
}

variable "remote_state_bucket" {
  description = "S3 Remote State bucket"
}

variable "remote_state_region" {
  description = "Remote State region"
}

variable "remote_state_key" {
  description = "State file path"
}

variable "dynamodb_table" {
  default = "DynamoDB table for state locking"
}

// bucket variable for codebuild role

variable "bucket_arn" {
  description = "Codebuild S3 Bucket arn"
  default = "arn:aws:s3:::codebuild-*"
}
