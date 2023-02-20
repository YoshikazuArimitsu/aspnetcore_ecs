resource "aws_ecr_repository" "webapp" {
  name                 = "${var.prefix}-ecr"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_image_url" {
  value = aws_ecr_repository.webapp.repository_url
}