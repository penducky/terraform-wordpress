provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project   = "TF-WORDPRESS"
      Terraform = true
    }
  }
}

module "infra" {
  source          = "./modules/infra"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = 2
  private_subnets = 2
  db_subnets      = 2
}

module "app" {
  source         = "./modules/app"
  public_subnet  = module.infra.public_subnet
  private_subnet = module.infra.private_subnet
  db_subnet      = module.infra.db_subnet
  lb_sg_id       = module.infra.lb_sg.id
  web_sg_id      = module.infra.web_sg.id
  db_sg_id       = module.infra.db_sg.id
  db_username    = var.db_username
  db_password    = var.db_password
  vpc_id         = module.infra.vpc.id
}