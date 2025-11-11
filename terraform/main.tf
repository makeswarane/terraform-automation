provider "aws" { region = var.aws_region }

module "networking" {
  source          = "./modules/networking"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

module "compute" {
  source         = "./modules/compute"
  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnets
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name
}

module "db" {
  source          = "./modules/db"
  private_subnets = module.networking.private_subnets
  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = var.db_password
  db_sg           = module.compute.ec2_sg_id
}

module "observability" {
  source = "./modules/observability"
}
