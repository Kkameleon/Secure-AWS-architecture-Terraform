terraform {
  required_version = ">=0.13.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.22"
    }
  }
  backend "remote" {
    organization = "telecom_imphackt_wavegame"

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
  #shared_credentials_file = "~/.aws/credentials"
  access_key = "AKIAWWXRSBFETOZA4C6H"
  secret_key = "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"
  #access_key = "AKIARYHVWQHP27JUPBE7"
  #secret_key = "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"
}
