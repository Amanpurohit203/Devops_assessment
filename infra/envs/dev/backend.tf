terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  #backend "s3" {
    #bucket         = "need to create s3 bucket for this backend"
    #key            = "dev/terraform.tfstate"
    #region         = "us-east-1"
    #dynamodb_table = "need db table "
    #encrypt        = true
  #}
}

provider "aws" {
  region = "us-east-1"
}