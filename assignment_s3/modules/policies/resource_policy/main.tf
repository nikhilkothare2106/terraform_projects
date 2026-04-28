# resource "aws_s3_bucket_policy" "dev_policy" {
#   bucket = var.dev_bucket.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       # {
#       #   "Sid" : "DenyStatement",
#       #   "Effect" : "Deny",
#       #   "Principal" : "*",
#       #   "Action" : "s3:*",
#       #   "Resource" : [
#       #     "${var.dev_bucket.arn}/*",
#       #     var.dev_bucket.arn
#       #   ],
#       #   "Condition" : {
#       #     "StringNotEquals" : {
#       #       "aws:PrincipalArn" : [
#       #         "arn:aws:iam::186581960368:root",
#       #         "arn:aws:iam::186581960368:user/Nikhil-DE",
#       #         var.replication_role_arn
#       #       ]
#       #     },
#       #     "ArnNotLike" : {
#       #       "aws:SourceArn" : var.aws_cloudfront_distribution_arn
#       #     }
#       #   }
#       # },
#       {
#         Sid       = "AllowCloudFrontOAC"
#         Effect    = "Allow"
#         Principal = { Service = "cloudfront.amazonaws.com" }
#         Action    = "s3:GetObject"
#         Resource  = "${var.dev_bucket.arn}/*"
#         Condition = {
#           StringEquals = {
#             "AWS:SourceArn" = var.aws_cloudfront_distribution_arn
#           }
#         }
#       }

#     ]
#   })
# }


# resource "aws_s3_bucket_policy" "stage_policy" {
#   bucket = var.stage_bucket.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         "Sid" : "DenyStatement",
#         "Effect" : "Deny",
#         "Principal" : "*",
#         "Action" : "s3:*",
#         "Resource" : [
#           "${var.stage_bucket.arn}/*",
#           var.stage_bucket.arn
#         ],
#         "Condition" : {
#           "StringNotEquals" : {
#             "aws:PrincipalArn" : [
#               "arn:aws:iam::186581960368:root",
#               "arn:aws:iam::186581960368:user/Nikhil-DE",
#               var.replication_role_arn
#             ]
#           },
#           # "ArnNotLike": {
#           #     "aws:SourceArn": "arn:aws:cloudfront::186581960368:distribution/E2VPIJSHIDI6D8"
#           # }
#         }
#       }
#     ]
#   })
# }



resource "aws_s3_bucket_policy" "policy" {
  for_each = var.s3_details
  bucket   = each.value.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # {
      #   "Sid" : "DenyStatement",
      #   "Effect" : "Deny",
      #   "Principal" : "*",
      #   "Action" : "s3:*",
      #   "Resource" : [
      #     "${each.value.arn}/*",
      #     each.value.arn
      #   ],
      #   "Condition" : {
      #     "StringNotEquals" : {
      #       "aws:PrincipalArn" : [
      #         "arn:aws:iam::186581960368:root",
      #         "arn:aws:iam::186581960368:user/Nikhil-DE",
      #         # var.replication_role_arn
      #       ]
      #     },
      #     "ArnNotLike" : {
      #       "aws:SourceArn" : var.aws_cloudfront_distribution_arn[each.key]
      #     }
      #   }
      # },


      {
        Sid       = "AllowCloudFrontOAC"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${each.value.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.aws_cloudfront_distribution_arn[each.key]
          }
        }
      }

    ]
  })
}
