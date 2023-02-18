resource "aws_ecr_repository" "webapp" {
  name                 = "${var.prefix}-ecr"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
