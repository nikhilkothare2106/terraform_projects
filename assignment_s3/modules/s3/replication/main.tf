# resource "aws_iam_role" "replication" {
#   name = "S3ReplicationRole"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = { Service = "s3.amazonaws.com" }
#     }]
#   })
# }

# resource "aws_iam_role_policy" "replication_policy" {
#   role = aws_iam_role.replication.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:ListBucket",
#           "s3:GetReplicationConfiguration",
#           "s3:GetObjectVersionForReplication",
#           "s3:GetObjectVersionAcl",
#           "s3:GetObjectVersionTagging",
#           "s3:GetObjectRetention",
#           "s3:GetObjectLegalHold"
#         ]
#         Resource = [
#           "${var.dev_bucket.arn}",
#           "${var.dev_bucket.arn}/*",
#           "${var.stage_bucket.arn}",
#           "${var.stage_bucket.arn}/*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:ReplicateObject",
#           "s3:ReplicateDelete",
#           "s3:ReplicateTags",
#           "s3:ObjectOwnerOverrideToBucketOwner"
#         ]
#         Resource = [
#           "${var.dev_bucket.arn}/*",
#           "${var.stage_bucket.arn}/*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_s3_bucket_replication_configuration" "dev_to_stage" {
#   bucket = var.dev_bucket.id
#   role   = aws_iam_role.replication.arn
#   rule {
#     id     = "dev_to_stage"
#     status = "Enabled"
#     destination {
#       bucket = var.stage_bucket.arn
#     }
#   }
# }

# resource "aws_s3_bucket_replication_configuration" "stage_to_dev" {
#   bucket = var.stage_bucket.id
#   role   = aws_iam_role.replication.arn
#   rule {
#     id     = "stage_to_dev"
#     status = "Enabled"
#     destination {
#       bucket        = var.dev_bucket.arn
#       storage_class = "STANDARD"
#     }
#   }
# }

# data "aws_caller_identity" "current" {}



resource "aws_iam_role" "replication" {
  name = "S3ReplicationRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "replication_policy" {
  name = "Replication_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetReplicationConfiguration",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold"
        ]
        Resource = flatten([
          for key, bucket in var.s3_details : [
            bucket.arn,
            "${bucket.arn}/*"
          ]
        ])
        # "${var.dev_bucket.arn}",
        # "${var.dev_bucket.arn}/*",
        # "${var.stage_bucket.arn}",
        # "${var.stage_bucket.arn}/*",


      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ]
        Resource = [
          for key, bucket in var.s3_details : "${bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication_policy_attachement" {
  role       = aws_iam_role.replication.id
  policy_arn = aws_iam_policy.replication_policy.arn
}



resource "aws_s3_bucket_replication_configuration" "replication" {
  for_each = var.replication_pairs

  bucket = var.s3_details[each.value.source].id
  role   = aws_iam_role.replication.arn

  rule {
    id     = each.key
    status = "Enabled"

    destination {
      bucket = var.s3_details[each.value.dest].arn
    }
 
  }
}