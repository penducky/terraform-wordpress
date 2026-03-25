# DATABASE
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

# AUTOSCALING GROUP
resource "aws_launch_template" "wordpress" {
  name                                 = "${var.project_name}-lt"
  image_id                             = var.ami_id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t3.micro"
  key_name                             = var.key_pair

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
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  force_delete        = true
  vpc_zone_identifier = [for subnet in var.private_subnet : subnet.id]

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]
}

# LOAD BALANCER
resource "aws_lb" "app" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [for subnet in var.public_subnet : subnet.id]
}

resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ROUTE53
data "aws_route53_zone" "main" {
  name = "penducky.click"
}

resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.subdomain}.${var.root_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}