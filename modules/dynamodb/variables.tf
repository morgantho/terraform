variable "aws_region" {
  default = "us-east-2"
  }

variable "aws_profile" {
  default = "default"
  }

variable "remote_state_bucket" {
  default = "morgantho-terraform-remote-state"
  }

variable "remote_state_key" {
  }

variable "remote_state_region" {
  default = "us-east-2"
  }

variable "dynamodb_table" {
  default = "terraform-state"
  }

variable "table_name" {
  }

variable "hash_key" {
  }

variable "attribute_name" {
  }

variable "attribute_type" {
  }
