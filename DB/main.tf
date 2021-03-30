provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket                  = "backendtfstate"
    key                     = "tfstate/vpn/DB.tfstate"
    region                  = "ap-south-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket                  = "backendtfstate"
    key                     = "tfstate/vpn.tfstate"
    region                  = "ap-south-1"
  }
}
