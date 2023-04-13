### Contains code to setup AWS infrastructure using terraform

#### Network module creates several resources for an AWS VPC. The specifics are as follows:

**Data "aws_availability_zones"**: This will query the available zones in the region and make it available to be used when creating resources.

**Resource "aws_vpc"**: This will create the VPC for the user to use.

**Resource "aws_internet_gateway"**: This creates an internet gateway so the user can access the VPC from different devices.

**Resource "aws_subnet"**: This will create two subnets (public and private), each with their own CIDR block.

**Resource "aws_route_table"**: This will create two route tables (public and private) that are associated with the subnets.

**Resource "aws_route_table_association"**: This will link the route table to a subnet
This module should be used in conjunction with others and combined with security, monitoring, logging and other services.

**Resource "aws_instance"**: This will create an ec2 instance that will host the web application

### Steps to run file
1. Initialization
```
Terraform init
```
2. Plan your infrastructure
```
Terraform plan
```
3. Deploy your infrastructure
```
Terraform apply
```

#### This command will import the certificate and private key files located at the specified paths into AWS ACM, using the profile specified by the <profile-name> argument. The certificate will be associated with the current AWS account and region.
```
aws acm import-certificate --profile <profile-name> --certificate fileb:///path/to/certificate.pem --private-key fileb:///path/to/private.key
```
Here is a more detailed explanation of each argument:

profile: The name of the profile to use. Profiles are used to store AWS credentials, so you can use different profiles for different accounts or environments.
certificate: The path to the PEM-encoded certificate file.
private-key: The path to the PEM-encoded private key file.