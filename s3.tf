resource "aws_s3_bucket" "my-bucket" {
  bucket = var.s3_bucket_name

  tags = merge(
    var.common_tags,
    {
      Name = "Terraform Drill Bucket"
    }
  )
}

resource "aws_s3_bucket_ownership_controls" "my-bucket" {
  bucket = aws_s3_bucket.my-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "my-bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.my-bucket]
  
  bucket = aws_s3_bucket.my-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "my-bucket" {
  bucket = aws_s3_bucket.my-bucket.id
  versioning_configuration {
    status = var.s3_versioning_enabled ? "Enabled" : "Disabled"
  }
}