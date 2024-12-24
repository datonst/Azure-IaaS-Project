variable "firewall_sku_tier" {
  type        = string
  description = "Firewall SKU."
  default     = "Premium" # Valid values are Standard and Premium
  validation {
    condition = contains(["Standard", "Premium"], var.firewall_sku_tier)
    error_message = "The sku must be one of the following: Standard, Premium"
  }
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Location for all resources."
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet."
}

variable "frontend_ip_configuration" {
  description = "Frontend IP configuration."
}

variable "lb_public_ip" {
  description = "Public IP address of the Load Balancer."
}

