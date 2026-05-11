resource "aws_iam_role" "lambda_role" {
  name = "lambda-s3-sqs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # CloudWatch logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
  Effect = "Allow"
  Action = [
    "ec2:CreateNetworkInterface",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DeleteNetworkInterface",
    "ec2:AssignPrivateIpAddresses",
    "ec2:UnassignPrivateIpAddresses"
  ]
  Resource = "*"
},

      # SQS
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.my_queue.arn
      },
      

      # SNS
    #   {
    #     Effect = "Allow"
    #     Action = "sns:Publish"
    #     Resource = "*"
    #   },

      # Secrets Manager
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.rds_secret.arn
      },

      # DynamoDB
    #   {
    #     Effect = "Allow"
    #     Action = [
    #       "dynamodb:PutItem"
    #     ]
    #     Resource = "*"
    #   },

      # KMS (important for encrypted SQS + Secrets)
    #   {
    #     Effect = "Allow"
    #     Action = [
    #       "kms:Decrypt",
    #       "kms:GenerateDataKey"
    #     ]
    #     Resource = "*"
    #   }
    ]
  })
}