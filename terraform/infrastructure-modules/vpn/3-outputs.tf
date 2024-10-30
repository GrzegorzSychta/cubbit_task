output "client_vpn_endpoint_id" {
  value = aws_ec2_client_vpn_endpoint.this.id
}

output "client_vpn_endpoint_dns_name" {
  value = aws_ec2_client_vpn_endpoint.this.dns_name
}

output "client_cidr_block" {
  value = var.client_cidr_block
}
