output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "private_route_table_id" {
    value = aws_route_table.private.id
}

output "gateway_id" {
    value = aws_internet_gateway.this.id
}