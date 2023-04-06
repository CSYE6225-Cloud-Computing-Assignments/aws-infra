data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Description = "Terraform generated VPC"
  }
}

resource "aws_internet_gateway" "vpc-igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "Internet Gateway"
    Description = "IGW attached to ${aws_vpc.vpc.id}"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr_block)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.public_route
    gateway_id = aws_internet_gateway.vpc-igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "rt_associations_public" {
  count          = length(var.public_subnet_cidr_block)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_block)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "rt_associations_private" {
  count          = length(var.private_subnet_cidr_block)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}


output "new_vpc_id" {
  value = aws_vpc.vpc.id
}
output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}
output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}
