# output "dev_bucket" {
#   description = "ARN and Id of dev bucket"
#   value = {
#     id  = aws_s3_bucket.dev_bucket.id
#     arn = aws_s3_bucket.dev_bucket.arn
#   }
# }

# output "stage_bucket" {
#   description = "ARN and Id of stage bucket"
#   value = {
#     id  = aws_s3_bucket.stage_bucket.id
#     arn = aws_s3_bucket.stage_bucket.arn
#   }
# }
# output "dev_version" {
#   value = aws_s3_bucket_versioning.dev_version

# }

# output "stage_version" {
#   value = aws_s3_bucket_versioning.stage_version
# }

# output "bucket_regional_domain_name" {
#   value = aws_s3_bucket.dev_bucket.bucket_regional_domain_name
# }

output "s3_details" {
  description = "All S3 bucket details with versioning"

  value = {
    for key, bucket in aws_s3_bucket.buckets :
    key => {
      id                          = bucket.id
      arn                         = bucket.arn
      bucket_regional_domain_name = bucket.bucket_regional_domain_name
      # versioning                  = aws_s3_bucket_versioning.version[key]
    }
  }
}