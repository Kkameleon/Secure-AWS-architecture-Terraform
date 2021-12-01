terraform {
  required_version = ">=0.13.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "remote" {
    organization = "telecom_imphackt_wavegame"

    workspaces {
      name = "secu"
    }
  }
}

# Configure the AWS Provider with the account used to build the AWS resources
provider "aws" {
  region  = var.region
  access_key = ""
  secret_key = ""
  #profile = "secu"
}
