
provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket         = "cubbit-terraform-state-bucket"
    key            = "dev/ec2/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "cubbit-terraform-lock-table"
    encrypt        = true
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket         = "cubbit-terraform-state-bucket"
    key            = "dev/vpc/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "cubbit-terraform-lock-table"
    encrypt        = true
  }
}

data "terraform_remote_state" "vpn" {
  backend = "s3"

  config = {
    bucket = "cubbit-terraform-state-bucket"
    key    = "dev/vpn/terraform.tfstate"
    region = "eu-west-2"
  }
}

module "ec2" {
  source = "../../../infrastructure-modules/ec2"

  env               = "dev"
  aws_region        = "eu-west-2"
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids        = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  key_name          = "terraform"
  allowed_ssh_cidrs = ["${data.terraform_remote_state.vpn.outputs.client_cidr_block}","${data.terraform_remote_state.vpc.outputs.vpc_cidr_block}"]

  instances = {
    "master" = {
      name          = "master"
      ami_id        = "ami-00bbb4f696c09e388"
      instance_type = "t3.medium"
      subnet_index  = 0
    },
    "worker1" = {
      name          = "worker1"
      ami_id        = "ami-00bbb4f696c09e388"
      instance_type = "t3.micro"
      subnet_index  = 1
    },
    "worker2" = {
      name          = "worker2"
      ami_id        = "ami-00bbb4f696c09e388"
      instance_type = "t3.micro"
      subnet_index  = 2
    }
  }

}
