# resource "aws_iam_policy" "s3_upload_policy" {
#   name = "S3_Upload_Policy"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:PutObject"
#         ]
#         Resource = [
#           "${var.dev_bucket.arn}/*",
#           "${var.stage_bucket.arn}/*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:ListAllMyBuckets"
#         ]
#         Resource = ["*"]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:ListBucket"
#         ]
#         Resource = [
#           var.dev_bucket.arn,
#           var.stage_bucket.arn
#         ]
#       }
#     ]

#   })
# }

resource "aws_iam_policy" "s3_upload_policy" {
  name = "S3_Upload_Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          for key, bucket in var.s3_details : "${bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          for key, bucket in var.s3_details : bucket.arn
        ]
      }
    ]

  })
}

data "aws_iam_user" "s3_upload_user" {
  user_name = "user-s3-upload"
}
data "aws_iam_user" "root_user" {
  user_name = "Nikhil-DE"
}

# resource "aws_iam_user_policy_attachment" "attach_upload" {
#   policy_arn = aws_iam_policy.s3_upload_policy.arn
#   user       = data.aws_iam_user.s3_upload_user.user_name
# }

resource "aws_iam_user_policy_attachment" "attach_upload" {
  policy_arn = aws_iam_policy.s3_upload_policy.arn
  user       = data.aws_iam_user.s3_upload_user.user_name
}