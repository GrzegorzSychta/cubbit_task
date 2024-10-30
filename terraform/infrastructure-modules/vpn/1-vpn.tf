resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = "${var.env} Client VPN Endpoint"
  server_certificate_arn = var.server_certificate_arn

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_certificate_arn
  }

  client_cidr_block = var.client_cidr_block

  connection_log_options {
    enabled = false
  }

  transport_protocol = var.transport_protocol
  dns_servers        = var.dns_servers
  split_tunnel       = var.split_tunnel
  security_group_ids = [aws_security_group.vpn_endpoint.id]
  vpc_id             = var.vpc_id

  tags = {
    Name = "${var.env}-client-vpn-endpoint"
  }
}

resource "aws_ec2_client_vpn_network_association" "this" {
  for_each               = toset(var.subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.vpc_cidr_block
  authorize_all_groups   = true
}
