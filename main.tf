module "vpc" {
  source                    = "./modules/network"
  vpc_cidr_block            = var.vpc_cidr_block
  private_subnet_count      = var.private_subnet_count
  private_subnet_cidr_block = var.private_subnet_cidr_block
  public_subnet_count       = var.public_subnet_count
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  public_route              = var.public_route

}