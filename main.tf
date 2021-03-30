provider "aws" {
  region                  = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket                  = "backendtfstate"
    key                     = "tfstate/vpn.tfstate"
    region                  = "ap-south-1"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  
  name                         = var.name
  cidr                         = var.vpc_cidr
  azs                          = split(",", var.azs)
  public_subnets               = ["172.17.1.0/24", "172.17.2.0/24", "172.17.3.0/24"]
  private_subnets              = ["172.17.5.0/24", "172.17.6.0/24", "172.17.7.0/24"]
  create_database_subnet_group = true
  enable_dns_hostnames         = true
  enable_dns_support           = true
  enable_nat_gateway           = true
}