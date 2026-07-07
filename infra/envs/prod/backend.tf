terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  #backend "s3" {
   # bucket         = "REPLACE_WITH_YOUR_TFSTATE_BUCKET"
    #key            = "prod/terraform.tfstate"
    #region         = "us-east-1"
    #dynamodb_table = "REPLACE_WITH_YOUR_LOCK_TABLE"
    #encrypt        = true
  #.}
}

provider "aws" {
  region = "us-east-1"
}