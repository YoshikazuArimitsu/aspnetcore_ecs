resource "aws_iam_role" "codepipeline_role" {
  name = "${var.prefix}-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "ecs-tasks.amazonaws.com",
            "codepipeline.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.prefix}_codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": [
            "iam:PassRole"
        ],
        "Resource": "*",
        "Effect": "Allow",
        "Condition": {
            "StringEqualsIfExists": {
                "iam:PassedToService": [
                    "ecs-tasks.amazonaws.com"
                ]
            }
        }
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:Put*"
      ],
      "Resource": [
        "${aws_s3_bucket.s3.arn}",
        "${aws_s3_bucket.s3.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "ecs:*",
        "ecr:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.prefix}-deploy-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.s3.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["S3Artifact"]

      configuration = {
        S3Bucket             = aws_s3_bucket.s3.bucket
        S3ObjectKey          = var.imagedefinitions_objectkey
        PollForSourceChanges = true
      }
    }

    action {
      name             = "ECRSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["ECRArtifact"]

      configuration = {
        ImageTag = "latest"
        RepositoryName = aws_ecr_repository.webapp.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["S3Artifact"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.ecs_cluster.arn
        ServiceName = aws_ecs_service.ecs.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
