provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

terraform {
  backend "s3" {
    bucket = var.remote_state_bucket
    key = var.remote_state_key
    region = var.remote_state_region
    dynamodb_table = var.dynamodb_table
  }
}

resource "aws_dynamodb_table" "dynamodb_table" {
  name = var.table_name
  hash_key = var.hash_key
  attribute {
    name = var.attribute_name
    type = var.attribute_type
  }

  tags = {
    terraform = "true"
  }
}
