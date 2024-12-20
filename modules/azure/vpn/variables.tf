variable "prefix" {
  description = "Prefix for resources"
  type        = string
  default     = "azure"
}

variable "azure_vpn_gateway_sku" {
  description = "Azure VPN Gateway SKU"
  type        = string
  default     = "VpnGw1"
}

# module.hub_vnet.subnets["vpn-subnet"].resource_id
variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "resource_group_location" {
  description = "Resource Group Location"
  type        = string
}

variable "local_gateway_address" {
  description = "Local Gateway Address"
  type        = string
}

variable "local_standby_gateway_address" {
  description = "Local Standby Gateway Address"
  type        = string
}

variable "vnet_cidr" {
  description = "VNET CIDR"
  type        = string
}

variable "connection_shared_key" {
  description = "Connection Shared Key"
  type        = string
}

variable "connection_standby_shared_key" {
  description = "Connection Standby Shared Key"
  type        = string
}