locals {
  azs = data.aws_availability_zones.available.names
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "tf-wordpress-vpc"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "main" {
  tags = {
    Name = "tf-wordpress-igw"
  }
}

resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.main.id
}

# SUBNETS
resource "aws_subnet" "public" {
  for_each          = { for i in range(var.public_subnets) : "public${i}" => i }
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value)
  availability_zone = local.azs[each.value % length(local.azs)]

  tags = {
    Name = "tf-wordpress-subnets-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each          = { for i in range(var.private_subnets) : "private${i}" => i }
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value + 10)
  availability_zone = local.azs[each.value % length(local.azs)]

  tags = {
    Name = "tf-wordpress-subnets-${each.key}"
  }
}

resource "aws_subnet" "db" {
  for_each          = { for i in range(var.db_subnets) : "db${i}" => i }
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value + 20)
  availability_zone = local.azs[each.value % length(local.azs)]

  tags = {
    Name = "tf-wordpress-subnets-${each.key}"
  }
}

# EIP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-gateway-eip"
  }
}

# NAT GATEWAY
resource "aws_nat_gateway" "web" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["public0"].id

  tags = {
    Name = "nat-gw"
  }

  depends_on = [aws_internet_gateway.main]
}

# ROUTE TABLES
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "tf-wordpress-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.web.id
  }

  tags = {
    Name = "tf-wordpress-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
