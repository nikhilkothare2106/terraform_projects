resource "aws_sns_topic" "sns_topic" {
  name = "topic-1"
}

resource "aws_sns_topic_subscription" "email_subscriber" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "nikhilkothare12@gmail.com"
}