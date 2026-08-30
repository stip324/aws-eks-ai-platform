resource "aws_ecr_repository" "vehicle_api" {
  name                 = "vehicle-api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "vehicle-api"
  }
}