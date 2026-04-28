# resource "aws_cloudfront_origin_access_control" "oac" {
#   name                              = "s3-oac"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }

# resource "aws_cloudfront_distribution" "site" {
#   enabled             = true
#   default_root_object = "index.html"
#   origin {
#     domain_name              = var.bucket_regional_domain_name
#     origin_id                = "s3-dev-origin"
#     origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
#   }
#   default_cache_behavior {
#     allowed_methods        = ["GET", "HEAD"]
#     cached_methods         = ["GET", "HEAD"]
#     target_origin_id       = "s3-dev-origin"
#     viewer_protocol_policy = "redirect-to-https"
#     forwarded_values {
#       query_string = false
#       cookies { forward = "none" }
#     }
#   }
#   restrictions {
#     geo_restriction { restriction_type = "none" }
#   }
#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }
# }




resource "aws_cloudfront_origin_access_control" "oac" {
  for_each                          = var.s3_details
  name                              = "${each.key}-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {


  for_each = var.s3_details
  tags = {
    Name = "${each.key}-cloud-distribution"
  }
  enabled             = true
  default_root_object = "index.html"
  origin {
    domain_name              = each.value.bucket_regional_domain_name
    origin_id                = "${each.key}-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac[each.key].id
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${each.key}-s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }
  restrictions {
    geo_restriction { restriction_type = "none" }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
