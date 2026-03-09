output "web_sg_id" {
  value = aws_security_group.web.id
}

output "web_subnet" {
  value = aws_subnet.web
}

output "db_subnet" {
  value = aws_subnet.db
}

output "db_sg" {
  value = aws_security_group.db
}