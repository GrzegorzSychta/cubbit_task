output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
    value = module.vpc.public_subnet_ids
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "private_route_table_id" {
    value = module.vpc.private_route_table_id
}

output "gateway_id" {
    value = module.vpc.gateway_id
}