provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket         = "cubbit-terraform-state-bucket"
    key            = "dev/vpc/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "cubbit-terraform-lock-table"
    encrypt        = true
  }
}

module "vpc" {
  source = "../../../infrastructure-modules/vpc"

  env             = "dev"
  vpc_cidr_block  = "10.0.0.0/16"
  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

}
