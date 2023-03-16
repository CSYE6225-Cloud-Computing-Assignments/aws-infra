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
  source                = "./modules/ec2"
  new_vpc_id            = module.vpc.new_vpc_id
  vpc_cidr_block        = var.vpc_cidr_block
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  ec2_instance_count    = var.ec2_instance_count
  key_pair_name         = var.key_pair_name
  application_port      = var.application_port
  ami_id                = var.ami_id
  aws_iam_role_s3       = module.iam.aws_iam_role_s3
  rds_instance          = module.rds.rds_instance
  rds_instance_endpoint = module.rds.rds_instance_endpoint
  created_bucket_name   = module.s3.created_bucket_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_name               = var.db_name
  db_port               = var.db_port
}

module "rds" {
  source                     = "./modules/rds"
  private_subnet_ids         = module.vpc.private_subnet_ids
  new_vpc_id                 = module.vpc.new_vpc_id
  application_security_group = module.ec2.application_security_group
  db_username                = var.db_username
  db_password                = var.db_password
  db_name                    = var.db_name
}

module "s3" {
  source      = "./modules/s3"
  aws_profile = var.aws_profile
}

module "iam" {
  source              = "./modules/iam"
  created_bucket_name = module.s3.created_bucket_name
}

module "r53" {
  source                  = "./modules/r53"
  hosted_zone_name        = var.hosted_zone_name
  webapp_server_public_ip = module.ec2.webapp_server_public_ip

}
