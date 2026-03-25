terraform {
  backend "s3" {
    bucket       = "penducky-wordpress-terraform-state-bucket"
    key          = "tf-infra/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}