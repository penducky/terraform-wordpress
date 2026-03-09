variable "db_username" {
  description = "Username for the MySQL database"
  type = string
  sensitive = true
}

variable "db_password" {
  description = "Password for the MySQL database"
  type = string
  sensitive = true
}

variable "web_sg_id" {
  description = "List of the web security group ID"
  type        = string
}

variable "web_subnet_id" {
  description = "List of the web subnet ID"
  type        = string
}

variable "db0_subnet_id" {
  description = "List of the db subnet ID"
  type        = string
}


variable "db1_subnet_id" {
  description = "List of the db subnet ID"
  type        = string
}

variable "db_sg_id" {
  description = "ID of the database security group"
  type        = string
}
