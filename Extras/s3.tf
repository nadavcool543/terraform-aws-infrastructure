resource "aws_s3_bucket" "my-bucket" {
  bucket = "nadav-bucket-24-11-98"

  tags = {
    Name        = "Terraform Drill Bucket"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
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
    status = "Enabled"
  }
}