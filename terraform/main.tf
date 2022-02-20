terraform {

  backend "local" {

  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = "~> 1"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

provider "aws" {
  region                  = "eu-west-1"
}
