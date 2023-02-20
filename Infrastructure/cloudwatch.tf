data "aws_iam_policy_document" "cloudwatch_events" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "codepipeline:StartPipelineExecution"
    ]
  }
}

data "aws_iam_policy_document" "cloudwatch_events_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudwatch_events" {
  name               = "${var.prefix}-codepipeline-cloudwatch-events"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_events_assume_role.json
}

resource "aws_iam_policy" "cloudwatch_events" {
  name   = "${var.prefix}-codepipeline-cloudwatch-events"
  policy = data.aws_iam_policy_document.cloudwatch_events.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_events" {
  role       = aws_iam_role.cloudwatch_events.name
  policy_arn = aws_iam_policy.cloudwatch_events.arn
}

resource "aws_cloudwatch_event_rule" "ecr" {
  name        = "${var.prefix}-codepipeline-ecr-event-rule"
  description = "Amazon CloudWatch Events rule to automatically start your pipeline when a change occurs in the Amazon ECR image tag."

  event_pattern = <<-JSON
  {
    "source": [
      "aws.ecr"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": [
        "ecr.amazonaws.com"
      ],
      "eventName": [
        "PutImage"
      ],
      "requestParameters": {
        "repositoryName": [
          "${aws_ecr_repository.webapp.name}"
        ],
        "imageTag": [
          "latest"
        ]
      }
    }
  }
  JSON

  depends_on = [aws_codepipeline.codepipeline]
}

resource "aws_cloudwatch_event_target" "ecr" {
  rule      = aws_cloudwatch_event_rule.ecr.name
  target_id = aws_cloudwatch_event_rule.ecr.name
  arn       = aws_codepipeline.codepipeline.arn
  role_arn  = aws_iam_role.cloudwatch_events.arn
}