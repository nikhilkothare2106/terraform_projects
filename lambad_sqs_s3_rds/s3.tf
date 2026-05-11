# S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-secure-bucket-123456-demo" # must be globally unique

  tags = {
    Name        = "MySecureBucket"
    Environment = "Dev"
  }
}

# Enable Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Server-Side Encryption using KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# # Block Public Access (important for security)
# resource "aws_s3_bucket_public_access_block" "block_public" {
#   bucket = aws_s3_bucket.my_bucket.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.my_bucket.id

  queue {
    queue_arn = aws_sqs_queue.my_queue.arn
    events    = ["s3:ObjectCreated:*"]  # trigger on upload

  }

  depends_on = [aws_sqs_queue_policy.allow_s3, aws_kms_key.kms]
}