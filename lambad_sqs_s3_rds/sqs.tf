# SQS Queue
resource "aws_sqs_queue" "my_queue" {
  name = "my-secure-queue"

  # Enable KMS encryption using existing key
  kms_master_key_id                 = aws_kms_key.kms.arn
  kms_data_key_reuse_period_seconds = 300  # cache data key (5 mins)

  # Optional settings
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400 # 1 day
 redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.my_dlq.arn
    maxReceiveCount     = 3
  })
  tags = {
    Name        = "MySecureQueue"
    Environment = "Dev"
  }
}


resource "aws_sqs_queue_policy" "allow_s3" {
  queue_url = aws_sqs_queue.my_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3SendMessage"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.my_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.my_bucket.arn
          }
        }
      }
    ]
  })
}


resource "aws_sqs_queue" "my_dlq" {
  name = "my-secure-queue-dlq"

  # Use same KMS key (optional but recommended)
  kms_master_key_id                 = aws_kms_key.kms.arn
  kms_data_key_reuse_period_seconds = 300

  message_retention_seconds = 1209600 # 14 days (max)

  tags = {
    Name        = "MyDLQ"
    Environment = "Dev"
  }
}