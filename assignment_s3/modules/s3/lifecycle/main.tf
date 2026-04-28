# resource "aws_s3_bucket_lifecycle_configuration" "dev_lifecycle" {
#   bucket = var.dev_bucket.id
#   rule {
#     id     = "lifecycle-rule"
#     status = "Enabled"
#     transition {
#       days          = 30
#       storage_class = "STANDARD_IA"
#     }
#     transition {
#       days          = 60
#       storage_class = "GLACIER"
#     }
#     expiration {
#       days = 90
#     }
#   }
# }

# resource "aws_s3_bucket_lifecycle_configuration" "stage_lifecycle" {
#   bucket = var.stage_bucket.id
#   rule {
#     id     = "lifecycle-rule"
#     status = "Enabled"
#     transition {
#       days          = 30
#       storage_class = "STANDARD_IA"
#     }
#     transition {
#       days          = 60
#       storage_class = "GLACIER"
#     }
#     expiration {
#       days = 90
#     }
#   }
# }

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  for_each = var.s3_details
  bucket   = each.value.id
  rule {
    id     = "lifecycle-rule"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
    expiration {
      days = 90
    }
  }
}