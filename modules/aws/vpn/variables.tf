variable "azure_vpn_gateway_asn" {
  description = "Azure VPN Gateway ASN"
  type = string
}

variable "azure_vpn_gateway_ip" {
  description = "Azure VPN Gateway IP"
  type = string
}

variable "prefix" {
  description = "Prefix for resources"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for VPN Gateway"
  type        = string
}

variable "destination_cidr_block" {
  description = "Destination CIDR Block for VPN Connection"
  type        = list(string)

}

variable "connection_shared_key" {
  description = "Shared Key for VPN Connection"
  type = string
}

variable "connection_standby_shared_key" {
  description = "Standby Shared Key for VPN Connection"
  type = string
}

variable "route_table_id" {
  description = "Route Table ID"
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
}