resource "aws_security_group" "application" {
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
    Name = "Application"
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
  vpc_security_group_ids      = [aws_security_group.application.id]
  associate_public_ip_address = "true"
  depends_on                  = [var.rds_instance]
  iam_instance_profile        = var.aws_iam_role_s3
  user_data                   = <<EOF
  #!/bin/bash
  echo "# App Environment Variables Setting Started" >> /var/log/user-data.log
  {
    echo "HOST_NAME=${var.rds_instance_endpoint}"
    echo "DB_USERNAME=${var.db_username}"
    echo "DB_PASSWORD=${var.db_password}"
    echo "DB_NAME=${var.db_name}"
    echo "DB_PORT=${var.db_port}"
    echo "S3_BUCKET_NAME=${var.created_bucket_name}"
  } >> /etc/environment
  chown -R ec2-user:www-data /var/www
  usermod -a -G www-data ec2-user
  sudo systemctl daemon-reload
  sudo systemctl start webapp.service
  sudo systemctl enable webapp.service
  sudo systemctl restart webapp.service
  sudo systemctl status webapp.service
  echo "# App Environment Variables Setting Ended" >> /var/log/user-data.log

  EOF
  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name = "Webapp_Server"
  }

}

output "application_security_group" {
  value = aws_security_group.application.id
}

output "webapp_server_public_ip" {
  value = [for instance in aws_instance.ec2 : instance.public_ip if instance.public_ip != null]
}