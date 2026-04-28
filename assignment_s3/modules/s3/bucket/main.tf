# resource "aws_s3_bucket" "dev_bucket" {
#   bucket        = var.dev_bucket
#   force_destroy = true
# }
# resource "aws_s3_bucket" "stage_bucket" {
#   bucket        = var.stage_bucket
#   force_destroy = true

# }


# resource "aws_s3_bucket_versioning" "dev_version" {
#   bucket = aws_s3_bucket.dev_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_versioning" "stage_version" {
#   bucket = aws_s3_bucket.stage_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }


resource "aws_s3_bucket" "buckets" {
  for_each      = var.buckets
  bucket        = each.value
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "version" {
  for_each = aws_s3_bucket.buckets
  bucket   = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "index_html" {
  for_each     = aws_s3_bucket.buckets
  bucket       = each.value.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  etag         = filemd5("${path.module}/index.html")
  content_type = "text/html"
}