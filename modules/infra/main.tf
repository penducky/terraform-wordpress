locals {
  azs = data.aws_availability_zones.available.names
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "tf-wordpress-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  tags = {
    Name = "tf-wordpress-igw"
  }
}

resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.main.id
}

resource "aws_subnet" "web" {
  for_each          = { for i in range(var.public_subnets) : "web${i}" => i }
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value)
  availability_zone = local.azs[each.value % length(local.azs)]

  tags = {
    Name = "tf-wordpress-subnets-${each.key}"
  }
}

resource "aws_subnet" "db" {
  for_each          = { for i in range(var.private_subnets) : "db${i}" => i }
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value + 20)
  availability_zone = local.azs[each.value % length(local.azs)]

  tags = {
    Name = "tf-wordpress-subnets-${each.key}"
  }
}

resource "aws_route_table" "web" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "tf-wordpress-web-rt"
  }
}

resource "aws_route_table_association" "web" {
  for_each       = aws_subnet.web
  subnet_id      = each.value.id
  route_table_id = aws_route_table.web.id
}