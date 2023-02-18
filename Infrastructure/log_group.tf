resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${var.prefix}-log"
  retention_in_days = 30
}
