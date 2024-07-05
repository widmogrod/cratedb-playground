terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.42"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "~> 1.17"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

provider "mongodbatlas" {
  public_key = var.mongodb_atlas_public_key
  private_key = var.mongodb_atlas_private_key
}

data "aws_caller_identity" "current" {}
