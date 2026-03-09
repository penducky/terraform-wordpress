variable "vpc_cidr" {
  description = "CIDR Block of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Number of public subnets"
  type        = number
}

variable "private_subnets" {
  description = "Number of private subnets"
  type        = number
}
