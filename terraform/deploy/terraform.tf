terraform {
  required_version = ">= 0.12"
  backend "s3" {
    key="tf-state"
  }
}



provider "aws" {
  region = "eu-west-2"
}
