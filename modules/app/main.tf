resource "aws_db_instance" "db" {
  allocated_storage      = 20
  db_name                = "wordpress"
  db_subnet_group_name   = aws_db_subnet_group.db.name
  availability_zone      = "us-east-1a"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.micro"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [var.db_sg_id]
}

resource "aws_db_subnet_group" "db" {
  name       = "db"
  subnet_ids = [for subnet in var.db_subnet : subnet.id]

  tags = {
    Name = "tf-wordpress-db-sg"
  }
}

resource "aws_launch_template" "wordpress" {
  name                                 = "wordpress-lt"
  image_id                             = "ami-0b6c6ebed2801a5cb"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t3.micro"
  key_name                             = "wordpress_key"

  lifecycle {
    create_before_destroy = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.web_sg_id]
  }

  user_data = base64encode(<<-EOT
#!/bin/bash -xe

sudo apt update -y
sudo apt upgrade -y


# Install apache server
sudo apt install -y apache2

# Install PHP
sudo apt install -y php
sudo apt install -y libapache2-mod-php php-mysql


# Install MySQL Client
sudo apt install -y mysql-client

# Define variable
DBName='wordpress'
DBUser='admin'
DBPassword='password'
DBRootPassword='password'
DBHost='${aws_db_instance.db.endpoint}'

# Install WordPress
sudo wget http://wordpress.org/latest.tar.gz
sudo tar -xvf latest.tar.gz
sudo rm latest.tar.gz
sudo mv wordpress /var/www/html/wordpress
cd /var/www/html/wordpress

# Update wp-config.php file
sudo cp ./wp-config-sample.php ./wp-config.php
sudo sed -i "s/'database_name_here'/'$DBName'/g" wp-config.php
sudo sed -i "s/'username_here'/'$DBUser'/g" wp-config.php
sudo sed -i "s/'password_here'/'$DBPassword'/g" wp-config.php   
sudo sed -i "s/'localhost'/'$DBHost'/g" wp-config.php   

# Reboot
sudo reboot
EOT
  )
}

resource "aws_autoscaling_group" "app" {
  name                = "app-asg"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 2
  force_delete        = true
  vpc_zone_identifier = [for subnet in var.private_subnet : subnet.id]
  
  launch_template {
    id = aws_launch_template.web.id
    version = "$Latest"    
  }


}