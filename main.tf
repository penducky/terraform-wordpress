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
}

module "app" {
  source        = "./modules/app"
  web_sg_id     = module.infra.web_sg_id
  web_subnet_id = module.infra.web_subnet["web0"].id
  db0_subnet_id = module.infra.db_subnet["db0"].id
  db1_subnet_id = module.infra.db_subnet["db1"].id
  db_sg_id      = module.infra.db_sg.id
  db_username   = var.db_username
  db_password   = var.db_password
}