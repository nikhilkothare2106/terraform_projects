module "bucket" {
  source  = "./modules/s3/bucket"
  buckets = var.buckets
}
module "iam_policy" {
  source     = "./modules/policies/iam_policy"
  s3_details = module.bucket.s3_details
}
module "s3_policy" {
  source                          = "./modules/policies/resource_policy"
  s3_details                      = module.bucket.s3_details
  aws_cloudfront_distribution_arn = module.cloudfront.aws_cloudfront_distribution_arn
}
module "logging" {
  source     = "./modules/s3/logging"
  s3_details = module.bucket.s3_details
}
module "lifecycle" {
  source     = "./modules/s3/lifecycle"
  s3_details = module.bucket.s3_details
}
module "replication" {
  source            = "./modules/s3/replication"
  s3_details        = module.bucket.s3_details
  replication_pairs = local.replication_pairs

}
module "cloudfront" {
  source     = "./modules/cloudfront"
  s3_details = module.bucket.s3_details
}
module "sns" {
  source = "./modules/sns"
}
module "lambda" {
  source     = "./modules/lambda"
  s3_details = module.bucket.s3_details
  topic_arn = module.sns.topic_arn
}

locals {
  replication_pairs = {
    pair1 = {
      source = "dev"
      dest   = "stage"
    }

    pair2 = {
      source = "stage"
      dest   = "prod"
    }
    pair3 = {
      source = "prod"
      dest   = "dev"
    }
  }
}