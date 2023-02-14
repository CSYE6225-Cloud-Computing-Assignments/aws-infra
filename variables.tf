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