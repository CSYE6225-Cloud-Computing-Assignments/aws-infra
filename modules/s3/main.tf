
locals {
  # Generate a random suffix to append to the bucket name
  suffix = substr(md5(random_id.my_id.hex), 0, 6)
}
resource "random_id" "my_id" {
  byte_length = 4
  prefix      = "my-prefix-"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-bucket-${var.aws_profile}-${local.suffix}"
}

resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  bucket = aws_s3_bucket.my_bucket.id
  rule {
    id     = "transition-to-standard-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

}

resource "aws_s3_bucket_acl" "my_bucket_acl" {
  bucket = aws_s3_bucket.my_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "created_bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}