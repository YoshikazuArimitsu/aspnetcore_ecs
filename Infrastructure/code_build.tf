data "aws_iam_policy_document" "codebuild_assume_role_policy_document" {
  statement {
    sid = "CodebuildExecution"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "${var.prefix}-codebuild"
  assume_role_policy = "${data.aws_iam_policy_document.codebuild_assume_role_policy_document.json}"
}

data "aws_iam_policy_document" "codebuild_policy_document" {
  statement {
    sid = "CloudWatch"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    sid = "ECR"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role = "${aws_iam_role.codebuild_role.name}"
  policy = "${data.aws_iam_policy_document.codebuild_policy_document.json}"
}

data "template_file" "buildspec_template_file" {
  template = <<EOF
version: 0.2

phases:
  pre_build:
    commands:
      - echo pre_build
      - echo Logging in to Amazon ECR...
      - $(aws ecr get-login --no-include-email --region ap-northeast-1)

  build:
    commands:
      - echo build
      - echo build docker image
      - docker build -t webapp -f ./Server/WebApplication1/Dockerfile ./Server

      - echo build unittest docker image
      - docker build -t webapp.test -f ./Server/WebApplication1.Test/Dockerfile ./Server

      - echo running unittest
      - mkdir /tmp/TestResults
      - docker run -v /tmp/TestResults:/TestResults webapp.test

  post_build:
    commands:
      - echo post_build
      - docker tag webapp:latest ${aws_ecr_repository.webapp.repository_url}:latest
      - docker push ${aws_ecr_repository.webapp.repository_url}:latest

reports:
  trx-report:
    files:
      - '**/*.trx'
    base-directory: /tmp/TestResults/
    file-format: VISUALSTUDIOTRX
  coverage:
    files:
      - '**/coverage.cobertura.xml'
    base-directory: /tmp/TestResults/
    file-format: COBERTURAXML
EOF
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "${var.prefix}-codebuild-project"
  description   = "${var.prefix}-codebuild-project"
  build_timeout = "30"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/docker:18.09.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "GITHUB"
    location  = "https://github.com/YoshikazuArimitsu/aspnetcore_ecs.git"
    buildspec = "${data.template_file.buildspec_template_file.rendered}"
  }
}