# output "aws_cloudfront_distribution_arn" {
#   value = aws_cloudfront_distribution.site.arn
# }

output "aws_cloudfront_distribution_arn" {
  value = {
    for key, distribution in aws_cloudfront_distribution.site :
    key => distribution.arn
  }
}