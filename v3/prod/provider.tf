terraform {
  required_version = ">=0.13.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.22"
    }
  }
  backend "remote" {
    organization = "VOTRE_ORGANISATION"

    workspaces {
      name = "prod"
    }
}
}

# Configure the AWS Provider with the account used to build the AWS resources
provider "aws" {
  max_retries = 1
  region  = var.region
  #profile = "prod"
  access_key = "REDACTED"
  secret_key = "REDACTED"
}
