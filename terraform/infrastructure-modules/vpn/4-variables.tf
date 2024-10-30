variable "env" {
  description = "Environment name."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for VPN association."
  type        = list(string)
}

variable "server_certificate_arn" {
  description = "ARN of the server certificate in ACM."
  type        = string
}

variable "client_certificate_arn" {
  description = "ARN of the client root certificate in ACM."
  type        = string
}

variable "client_cidr_block" {
  description = "CIDR block for VPN clients."
  type        = string
}

variable "transport_protocol" {
  description = "Transport protocol (udp or tcp)."
  type        = string
  default     = "udp"
}

variable "vpn_port" {
  description = "Port number for the VPN endpoint."
  type        = number
  default     = 443
}

variable "dns_servers" {
  description = "List of DNS servers for VPN clients."
  type        = list(string)
  default     = []
}

variable "split_tunnel" {
  description = "Enable split-tunnel."
  type        = bool
  default     = true
}

variable "allowed_ips" {
  description = "List of CIDR blocks allowed to access the VPN endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "private_route_table_id" {
  description = "value"
}

variable "gateway_id" {
  description = "value"
}