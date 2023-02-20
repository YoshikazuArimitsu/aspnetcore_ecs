resource "aws_cloudtrail" "cloudtrail" {
  name           = "${var.prefix}-codepipeline-trail"
  s3_bucket_name = aws_s3_bucket.s3.id

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }
}
