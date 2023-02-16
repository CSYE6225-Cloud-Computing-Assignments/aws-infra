### Contains code to setup AWS infrastructure using terraform

#### Network module creates several resources for an AWS VPC. The specifics are as follows:

**Data "aws_availability_zones"**: This will query the available zones in the region and make it available to be used when creating resources.

**Resource "aws_vpc"**: This will create the VPC for the user to use.

**Resource "aws_internet_gateway"**: This creates an internet gateway so the user can access the VPC from different devices.

**Resource "aws_subnet"**: This will create two subnets (public and private), each with their own CIDR block.

**Resource "aws_route_table"**: This will create two route tables (public and private) that are associated with the subnets.

**Resource "aws_route_table_association"**: This will link the route table to a subnet
This module should be used in conjunction with others and combined with security, monitoring, logging and other services.
