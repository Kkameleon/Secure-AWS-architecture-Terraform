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
      name = "secu"
    }
  }
}

# Configure the AWS Provider with the account used to build the AWS resources
provider "aws" {
  region  = var.region
  access_key = "REDACTED"
  secret_key = "REDACTED"
  #profile = "secu"
}
