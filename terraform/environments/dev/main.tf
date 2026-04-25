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
  private_subnet_id = module.vpc.private_subnet_id
  public_subnet_id = module.vpc.public_subnet_id
}

module "compute" {
  source = "../../modules/compute"
  private_subnet_id = module.vpc.private_subnet_id
  private_sg_id = module.security.private_sg_id
}