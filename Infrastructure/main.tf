variable "prefix" {
  default = "examplewebapp"
}

variable "bucket" {
  default = "examplewebapp-codepipeline-bucket"
}

variable "imagedefinitions_objectkey" {
  default = "code_pipeline/imagedefinitions.json.zip"
}

variable "imagedefinition" {
  default = "./imagedefinitions.json.zip"
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
