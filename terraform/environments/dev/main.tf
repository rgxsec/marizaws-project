provider "aws" {
    region = "eu-west-1"
}

module "vpc" {
  source = "../../modules/vpc"
  cidr_block = var.cidr_block
  public_subnet = var.public_subnet
  private_subnet = var.private_subnet
}


module "security" {
  source = "../../modules/security"
  vpc_id = module.vpc.vpc_id
}