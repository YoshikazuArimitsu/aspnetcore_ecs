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

resource "aws_s3_bucket_policy" "access_from_cloudtrail" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.access_from_cloudtrail.json
}

data "aws_iam_policy_document" "access_from_cloudtrail" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.s3.bucket}",
    ]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.s3.bucket}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.s3.bucket
  key    = var.imagedefinitions_objectkey
  source = var.imagedefinition
}

