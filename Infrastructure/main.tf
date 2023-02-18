variable "prefix" {
  default = "examplewebapp"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket  = "yarimit"
    region  = "ap-northeast-1"
    key     = "aspnetcore_ecs.tfstate"
    encrypt = true
  }
}
