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
  vpc_security_group_ids = [aws_security_group.db.id]
}

resource "aws_db_subnet_group" "db" {
  name       = "db"
  subnet_ids = [for subnet in var.db_subnet : subnet.id]

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

resource "aws_launch_template" "wordpress" {
  name                                 = "${var.project_name}-lt"
  image_id                             = "ami-0b6c6ebed2801a5cb"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t3.micro"
  key_name                             = "wordpress_key"

  lifecycle {
    create_before_destroy = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web.id]
  }

  user_data = base64encode(templatefile("${path.module}/user_data.tftpl",
  { db_endpoint = aws_db_instance.db.endpoint }))
}

resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-web-asg"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 2
  force_delete        = true
  vpc_zone_identifier = [for subnet in var.private_subnet : subnet.id]

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.lb.arn]
}

resource "aws_lb" "lb" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [for subnet in var.public_subnet : subnet.id]
}

resource "aws_lb_target_group" "lb" {
  name     = "${var.project_name}-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "lb" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb.arn
  }
}