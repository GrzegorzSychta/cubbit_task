provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket         = "cubbit-terraform-state-bucket"
    key            = "dev/vpn/terraform.tfstate"
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
  }
}

module "vpn" {
  source = "../../../infrastructure-modules/vpn"

  env                    = "dev"
  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr_block         = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  subnet_ids             = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  server_certificate_arn = "arn:aws:acm:eu-west-2:058264075563:certificate/b5531e3b-1266-4cd9-bc02-98b96d84415b"
  client_certificate_arn = "arn:aws:acm:eu-west-2:058264075563:certificate/c5546b25-73a1-4aa4-a146-65b51d92584c"
  client_cidr_block      = "10.11.0.0/22"
  transport_protocol     = "udp"
  vpn_port               = 443
  dns_servers            = ["8.8.8.8", "8.8.4.4"]
  split_tunnel           = true
  allowed_ips            = ["10.0.0.0/16"]
}
