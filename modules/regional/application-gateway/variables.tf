variable "location" {
  description = "Location of the resource"
  type        = string
}

variable "sku_name" {
  description = "SKU of the NAT Gateway"
  type        = string
}


variable "appgw_name" {
  description = "Name of the application gateway"
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

variable "frontend_port" {
  description = "Frontend port of the application gateway"
  type        = number
  default = 80
}

variable "backend_port" {
  description = "Backend port of the application gateway"
  type        = number
  default = 80
}

variable "subnet_id" {
  description = "Subnet ID of the application gateway"
  type        = string
}

