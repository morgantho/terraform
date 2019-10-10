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

variable "vpc_cidr" {
  description = "Cidr block"
}

variable "subnet_cidr" {
  description = "Subnet cidr blocks"
  type = "list"
}

variable "availablity_zones" {
  description = "Availablity zones"
  type = "list"
}

variable "public_ip_response" {
  default = "false"
}
