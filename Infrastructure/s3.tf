resource "aws_s3_bucket" "s3" {
  bucket        = var.bucket
  force_destroy = true

  tags = {
    Name = var.bucket
  }
}

resource "aws_s3_bucket_acl" "s3" {
  bucket = aws_s3_bucket.s3.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "s3" {
  bucket = aws_s3_bucket.s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.s3.bucket
  key    = var.imagedefinitions_objectkey
  source = var.imagedefinition
}

