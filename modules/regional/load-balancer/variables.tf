variable "location" {
  description = "Location of the NAT Gateway"
  type        = string
}

variable "sku_name" {
  description = "SKU of the NAT Gateway"
  type        = string
}


variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "allocation_method" {
  description = "Allocation method of the public IP"
  type        = string
  default = "Static"
}

variable "zones" {
  description = "Zones of the NAT Gateway"
  type        = list(string)
  default     = ["1"]
}