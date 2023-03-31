variable "aws_profile" {
  type        = string
  description = "The AWS account you intend to use"
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "The AWS region you intend to use"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnet_count" {
  type    = number
  default = 3
}

variable "private_subnet_cidr_block" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_count" {
  type    = number
  default = 3
}
variable "public_subnet_cidr_block" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "public_route" {
  type    = string
  default = "0.0.0.0/0"
}

variable "key_pair_name" {
  type    = string
  default = "ec2"
}

variable "ec2_instance_count" {
  type    = number
  default = 1
}

output "new_vpc_id" {
  value = module.vpc.new_vpc_id
}

variable "application_port" {
  type    = number
  default = 8080
}

variable "ami_id" {
  type    = string
  default = "ami-0dfcb1ef8550277af"

}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_port" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "cloud_agent_policy_arn" {
  type = string
}

output "webapp_server_public_ip" {
  value = module.ec2.webapp_server_public_ip
}