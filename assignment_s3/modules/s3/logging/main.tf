
# resource "aws_s3_bucket" "logs" {
#   bucket        = "log-bucket-demo-1234"
#   force_destroy = true

# }

# resource "aws_s3_bucket_logging" "dev_logging" {
#   bucket        = var.dev_bucket.id
#   target_bucket = aws_s3_bucket.logs.id
#   target_prefix = "dev-logs/"
# }

# resource "aws_s3_bucket_logging" "stage_logging" {
#   bucket        = var.stage_bucket.id
#   target_bucket = aws_s3_bucket.logs.id
#   target_prefix = "stage-logs/"
# }


resource "aws_s3_bucket" "logs" {
  bucket        = "log-bucket-demo-1234"
  force_destroy = true

}

resource "aws_s3_bucket_logging" "logging" {
  for_each      = var.s3_details
  bucket        = each.value.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = each.key
}
