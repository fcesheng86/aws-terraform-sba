terraform {

  backend "s3" {
    bucket = "jupiters3-280422"
    key    = "prod/nicTF"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.10.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "ap-south-1"
  alias  = "apsouth1"
}
