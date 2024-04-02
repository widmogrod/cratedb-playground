terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.42"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.aws_region
}


variable "aws_region" {
    default = "eu-west-1"
}