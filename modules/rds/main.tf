##creating rds using terraform
resource "aws_db_instance" "webapp_rds" {
  # count                  = 1
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  multi_az               = false
  identifier             = "csye6225"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_private_subnet_group.name
  publicly_accessible    = false
  db_name                = var.db_name
  parameter_group_name   = aws_db_parameter_group.rds-pg.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database.id]
  allocated_storage      = 20

  tags = {
    name = "Webapp_Database"
  }

}

##parameter group
resource "aws_db_parameter_group" "rds-pg" {
  name   = "rds-pg"
  family = "mysql8.0"
}

##DB security group
resource "aws_security_group" "database" {
  name        = "Database"
  description = "database security group"
  vpc_id      = var.new_vpc_id

  ingress {
    description     = "HTTPS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.application_security_group]
    # source_security_group_id = var.application_security_group.id 
    # cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "database"
  }
}

resource "aws_db_subnet_group" "db_private_subnet_group" {
  subnet_ids = tolist(var.private_subnet_ids)
  tags = {
    Name = "My DB subnet group"
  }
}

output "rds_instance" {
  value = aws_db_instance.webapp_rds

}

output "rds_instance_endpoint" {
  value = element(split(":", aws_db_instance.webapp_rds.endpoint), 0)

}