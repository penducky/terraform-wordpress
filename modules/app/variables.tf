variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "public_subnet" {
  description = "List of the public subnet object"
  type        = map(any)
}

variable "private_subnet" {
  description = "List of the web subnet object"
  type        = map(any)
}

variable "db_subnet" {
  description = "List of the db subnet object"
  type        = map(any)
}

variable "vpc_id" {
  description = "ID of the VPC"
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

variable "ami_id" {
  description = "ID of the AMI for the instance"
  type = string
}

variable "max_size" {
  description = "Maximum amount of instance allowed for autoscaling group"
  type        = number
}

variable "min_size" {
  description = "Minimum amount of instance allowed for autoscaling group"
  type        = number
}

variable "desired_capacity" {
  description = "Desired amount of instance allowed for autoscaling group"
  type        = number
}