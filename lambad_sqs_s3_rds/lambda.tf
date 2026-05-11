resource "aws_lambda_function" "s3_processor" {
  function_name = "s3-sqs-processor"

  filename         = "lambda.zip"
  handler          = "lambda.lambda_handler"
  runtime          = "python3.14"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = filebase64sha256("lambda.zip")

  timeout = 30

  environment {
    variables = {
      # SNS_TOPIC_ARN = aws_sns_topic.my_topic.arn
      SECRET_NAME   = aws_secretsmanager_secret.rds_secret.name
    }
  }

  layers = [
    aws_lambda_layer_version.pymysql_layer.arn
  ]
  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id,
      aws_subnet.private_subnet_3.id
    ]
    

    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}


resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.my_queue.arn
  function_name    = aws_lambda_function.s3_processor.arn

  batch_size = 10   # number of messages per invocation

  # Optional tuning
  maximum_batching_window_in_seconds = 5
  enabled                            = true
}


resource "aws_lambda_layer_version" "pymysql_layer" {
  filename   = "${path.module}/pymysql-layer1.zip"
  layer_name = "pymysql-layer"

  compatible_runtimes = ["python3.14"]

  source_code_hash = filebase64sha256("${path.module}/pymysql-layer1.zip")

  description = "PyMySQL dependency layer"
}