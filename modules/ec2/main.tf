resource "aws_security_group" "allow_tcp" {
  name        = "Application"
  description = "Application security group"
  vpc_id      = var.new_vpc_id

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tcp"
  }

}

# resource "aws_network_interface" "ec2_interface"{
#     subnet_id = var.public_subnet_ids[0]
#     security_groups = aws_security_group.allow_tcp
# }

resource "aws_instance" "ec2" {

  count                       = var.ec2_instance_count
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.key_pair_name
  subnet_id                   = var.public_subnet_ids[count.index]
  vpc_security_group_ids      = [aws_security_group.allow_tcp.id]
  associate_public_ip_address = "true"

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name = "Webapp_server"
  }

}