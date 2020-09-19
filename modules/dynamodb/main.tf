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
