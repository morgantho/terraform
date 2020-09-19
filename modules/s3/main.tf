resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name

  versioning {
    enabled = var.versioning
  }

  server_side_encryption {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
