variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "db_username" {
  description = "Username for the MySQL database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the MySQL database"
  type        = string
  sensitive   = true
}

variable "public_subnet" {
  description = "List of the public subnet ID"
  type        = map(any)
}

variable "private_subnet" {
  description = "List of the web subnet ID"
  type        = map(any)
}

variable "db_subnet" {
  description = "List of the db subnet ID"
  type        = map(any)
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}