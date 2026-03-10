# LOAD BALANCER SG
resource "aws_security_group" "lb" {
  vpc_id      = aws_vpc.main.id
  description = "Load balancer security group"

  name = "lb-sg"
}

resource "aws_vpc_security_group_ingress_rule" "all_to_lb" {
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
  tags = {
    Name = "Allow any connections from internet"
  }
}

resource "aws_vpc_security_group_egress_rule" "lb_to_all" {
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
  tags = {
    Name = "Allow any connections to internet"
  }
}

resource "aws_vpc_security_group_egress_rule" "lb_to_web" {
  security_group_id            = aws_security_group.lb.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80

  tags = {
    Name = "Allow HTTP connections to the web security group"
  }
}

# WEB SG
resource "aws_security_group" "web" {
  vpc_id      = aws_vpc.main.id
  description = "Web security group"

  name = "web-sg"
}

resource "aws_vpc_security_group_ingress_rule" "lb_to_web" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.lb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "web_to_db" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306

  tags = {
    Name = "Allow MySQL connections to the database security group"
  }
}

resource "aws_vpc_security_group_egress_rule" "web_to_all" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1

  tags = {
    Name = "Allow any connections to the internet"
  }
}


# DATABASE SG
resource "aws_security_group" "db" {
  vpc_id      = aws_vpc.main.id
  description = "db tier security group"

  name = "db-sg"
}

resource "aws_vpc_security_group_ingress_rule" "web_to_db" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306


  tags = {
    Name = "Allow MySQL connections from the web security group"
  }
}

resource "aws_vpc_security_group_egress_rule" "db_to_all" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1

  tags = {
    Name = "Allow any connections to the internet"
  }
}

