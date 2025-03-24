terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.90.0"
    }
  }

  required_version = ">= 1.3"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}