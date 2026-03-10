output "vpc" {
  value = aws_vpc.main
}

output "public_subnet" {
  value = aws_subnet.public
}

output "private_subnet" {
  value = aws_subnet.private
}

output "db_subnet" {
  value = aws_subnet.db
}

output "lb_sg" {
  value = aws_security_group.lb
}

output "web_sg" {
  value = aws_security_group.web
}

output "db_sg" {
  value = aws_security_group.db
}
