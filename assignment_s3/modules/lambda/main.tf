# resource "aws_lambda_function" "s3_trigger" {
#   function_name    = "S3UploadTrigger"
#   runtime          = "python3.14"
#   handler          = "lambda.lambda_handler"
#   role             = aws_iam_role.lambda_exec.arn
#   filename         = "${path.module}/lambda.zip"
#   source_code_hash = filebase64sha256("${path.module}/lambda.zip")
# }

# resource "aws_iam_role" "lambda_exec" {
#   name = "lambda_s3_exec_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = { Service = "lambda.amazonaws.com" }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_logs" {
#   role       = aws_iam_role.lambda_exec.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }
# resource "aws_iam_role_policy_attachment" "sns" {
#   role       = aws_iam_role.lambda_exec.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
# }

# resource "aws_lambda_permission" "allow_s3" {
#   statement_id  = "AllowS3Invoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.s3_trigger.function_name
#   principal     = "s3.amazonaws.com"
#   source_arn    = var.dev_bucket.arn
# }

# resource "aws_s3_bucket_notification" "s3_lambda_trigger" {
#   bucket = var.dev_bucket.id
#   lambda_function {
#     lambda_function_arn = aws_lambda_function.s3_trigger.arn
#     events              = ["s3:ObjectCreated:*"]
#   }
#   depends_on = [aws_lambda_permission.allow_s3]
# }







resource "aws_iam_role" "lambda_exec" {
  name = "lambda_s3_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}
resource "aws_lambda_function" "s3_trigger" {
  function_name    = "S3UploadTrigger"
  runtime          = "python3.14"
  handler          = "lambda.lambda_handler"
  role             = aws_iam_role.lambda_exec.arn
  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
  environment {
    variables = {
      SNS_TOPIC_ARN = var.topic_arn
    }
  }
}


resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "sns" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}


resource "aws_lambda_permission" "allow_s3" {
  for_each      = var.s3_details
  statement_id  = "${each.key}-AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = each.value.arn
}

resource "aws_s3_bucket_notification" "s3_lambda_trigger" {

  for_each = var.s3_details
  bucket   = each.value.id

  lambda_function {
    id                  = "UploadDeleteTrigger"
    lambda_function_arn = aws_lambda_function.s3_trigger.arn
    # events              = ["s3:ObjectCreated:*"]
    events = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:*",
      "s3:ObjectRestore:*",
      "s3:Replication:*",
      "s3:ObjectTagging:*",
      "s3:ObjectAcl:Put"
    ]
  }
  depends_on = [aws_lambda_permission.allow_s3]
}
