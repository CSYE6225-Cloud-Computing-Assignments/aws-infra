terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.0, <5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}