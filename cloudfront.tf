# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${var.project_name}-s3-oac"
  description                       = "Origin Access Control for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [
    aws_s3_bucket_acl.my-bucket,
    aws_s3_bucket_ownership_controls.my-bucket
  ]

  enabled = true
  
  # Origin configuration
  origin {
    domain_name              = aws_s3_bucket.my-bucket.bucket_regional_domain_name
    origin_id                = "myS3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }
  
  # Default cache behavior
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "myS3Origin"
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  
  # Logging configuration
  logging_config {
    include_cookies = false
    bucket         = aws_s3_bucket.my-bucket.bucket_regional_domain_name
    prefix         = "${var.project_name}-${var.cloudfront_log_prefix}/"
  }
  
  # Required restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  # SSL certificate
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  price_class = var.cloudfront_price_class
  
  tags = merge(
    var.common_tags,
    {
      Name = "Main CloudFront Distribution"
    }
  )
} 