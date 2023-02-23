module "vpc" {
  source                    = "./modules/network"
  vpc_cidr_block            = var.vpc_cidr_block
  private_subnet_count      = var.private_subnet_count
  private_subnet_cidr_block = var.private_subnet_cidr_block
  public_subnet_count       = var.public_subnet_count
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  public_route              = var.public_route

}

module "ec2" {
  source             = "./modules/ec2"
  new_vpc_id         = module.vpc.new_vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_instance_count = var.ec2_instance_count
  key_pair_name      = var.key_pair_name
  application_port   = var.application_port
  ami_id             = var.ami_id
}