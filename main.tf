locals {
  project_name = "tf-wordpress"
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project   = local.project_name
      Terraform = true
    }
  }
}


provider "aws" {
  alias   = "dev"
  region  = "us-east-1"
  profile = "iamadmin-general"
  default_tags {
    tags = {
      Project   = local.project_name
      Terraform = true
    }
  }
}

module "infra" {
  source          = "./modules/infra"
  project_name    = local.project_name
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = 2
  private_subnets = 2
  db_subnets      = 2
}

module "app" {
  source           = "./modules/app"
  project_name     = local.project_name
  public_subnet    = module.infra.public_subnet
  private_subnet   = module.infra.private_subnet
  db_subnet        = module.infra.db_subnet
  vpc_id           = module.infra.vpc.id
  db_username      = var.db_username
  db_password      = var.db_password
  db_name          = "wordpress"
  ami_id           = "ami-0b6c6ebed2801a5cb"
  key_pair         = "wordpress_key2"
  max_size         = 2
  min_size         = 1
  desired_capacity = 1
  root_domain      = "penducky.click"
  subdomain        = "wordpress"
}