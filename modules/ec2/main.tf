# Fetch the Availability Zones for the current region
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_security_group" "application" {
  name        = "Application"
  description = "Application security group"
  vpc_id      = var.new_vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.load_balancer.id]
  }
  ingress {
    description = "App Port"
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.load_balancer.id]
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

resource "aws_security_group" "load_balancer" {
  name        = "Load Balancer SG"
  description = "Load Balancer security group"
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
  # ingress {
  #   description = "Allow SSH"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Load Balancer SG"
  }
}

resource "aws_lb_target_group" "webapp_target_group" {
  name        = "webapp-lb-tg"
  port        = var.application_port
  protocol    = "HTTP"
  vpc_id      = var.new_vpc_id
  target_type = "instance"
  health_check {
    enabled           = true
    healthy_threshold = 3
    interval          = 30
    matcher           = "200"
    path              = "/healthz"
    port              = 8080
    protocol          = "HTTP"
  }
  tags = {
    Name = "webapp_target_group"
  }
}

resource "aws_lb" "webapp_load_balancer" {
  name                       = "webapp-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer.id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false
  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "webapp_lb_listner" {
  load_balancer_arn = aws_lb.webapp_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_target_group.arn
  }
}

# resource "aws_network_interface" "ec2_interface"{
#     subnet_id = var.public_subnet_ids[0]
#     security_groups = aws_security_group.allow_tcp
# }


resource "aws_launch_template" "asg_launch_config" {
  name          = "Webapp-Server-lt"
  depends_on    = [var.rds_instance]
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_pair_name
  user_data     = base64encode(data.template_file.user_data.rendered)
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 50
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.application.id]
  }
  iam_instance_profile {
    name = var.aws_iam_role_s3
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Webapp_Server"
    }
  }
}
data "template_file" "user_data" {

  template = <<EOF
  #!/bin/bash
  echo "# App Environment Variables Setting Started" >> /var/log/user-data.log
  {
    echo "NODE_ENV=production"
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
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/home/ec2-user/webapp/amazon-cloudwatch-agent.json -s >> /var/log/user-data.log
  echo "# App Environment Variables Setting Ended" >> /var/log/user-data.log
 EOF
}

resource "aws_autoscaling_group" "webapp_asg" {
  name = "webapp_asg"
  #availability_zones = data.aws_availability_zones.available.names
  vpc_zone_identifier = var.public_subnet_ids
  max_size            = 3
  min_size            = 1
  desired_capacity    = 1
  default_cooldown    = 60
  tag {
    key                 = "Name"
    value               = "Webapp_server"
    propagate_at_launch = true
  }
  launch_template {
    id      = aws_launch_template.asg_launch_config.id
    version = "$Latest"
  }
  target_group_arns = [
    aws_lb_target_group.webapp_target_group.arn
  ]
}

resource "aws_autoscaling_attachment" "webapp_asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.id
  lb_target_group_arn    = aws_lb_target_group.webapp_target_group.arn
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "ScaleUpPolicy"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  cooldown               = 60
  scaling_adjustment     = 1
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "ScaleDownPolicy"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  cooldown               = 60
  scaling_adjustment     = -1
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "terraform-scaleUp"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
  alarm_description         = "scale up when average cpu is above 5%"
  alarm_actions             = ["${aws_autoscaling_policy.scale_up_policy.arn}"]
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "terraform-scaleDown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "3"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
  alarm_description         = "scale down when average cpu is below 3%"
  alarm_actions             = ["${aws_autoscaling_policy.scale_down_policy.arn}"]
  insufficient_data_actions = []
}


# resource "aws_instance" "ec2" {

#   count                       = var.ec2_instance_count
#   ami                         = var.ami_id
#   instance_type               = "t2.micro"
#   key_name                    = var.key_pair_name
#   subnet_id                   = var.public_subnet_ids[count.index]
#   vpc_security_group_ids      = [aws_security_group.application.id]
#   associate_public_ip_address = "true"
#   depends_on                  = [var.rds_instance]
#   iam_instance_profile        = var.aws_iam_role_s3
#   user_data                   = <<EOF
#   #!/bin/bash
#   echo "# App Environment Variables Setting Started" >> /var/log/user-data.log
#   {
#     echo "NODE_ENV=production"
#     echo "HOST_NAME=${var.rds_instance_endpoint}"
#     echo "DB_USERNAME=${var.db_username}"
#     echo "DB_PASSWORD=${var.db_password}"
#     echo "DB_NAME=${var.db_name}"
#     echo "DB_PORT=${var.db_port}"
#     echo "S3_BUCKET_NAME=${var.created_bucket_name}"
#   } >> /etc/environment
#   chown -R ec2-user:www-data /var/www
#   usermod -a -G www-data ec2-user
#   sudo systemctl daemon-reload
#   sudo systemctl start webapp.service
#   sudo systemctl enable webapp.service
#   sudo systemctl restart webapp.service
#   sudo systemctl status webapp.service
#   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl     -a fetch-config     -m ec2     -c file:/home/ec2-user/webapp/amazon-cloudwatch-agent.json     -s
#   echo "# App Environment Variables Setting Ended" >> /var/log/user-data.log

#   EOF
#   root_block_device {
#     volume_size = 50
#     volume_type = "gp2"
#   }
#   tags = {
#     Name = "Webapp_Server"
#   }

# }

output "application_security_group" {
  value = aws_security_group.application.id
}

output "aws_lb_dns_name" {
  value = aws_lb.webapp_load_balancer.dns_name
}

output "aws_lb_zone_id" {
  value = aws_lb.webapp_load_balancer.zone_id
}

# output "webapp_server_public_ip" {
#   value = [for instance in aws_instance.ec2 : instance.public_ip if instance.public_ip != null]
# }
