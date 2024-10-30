resource "aws_security_group" "this" {
  name        = "${var.env}-vpn-endpoint-sg"
  description = "Security group for VPN endpoint"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all traffic within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_ips
  }

  ingress {
    description = "Allow VPN connections from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-vpn-endpoint-sg"
  }
}
