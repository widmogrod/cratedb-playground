terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.42"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
