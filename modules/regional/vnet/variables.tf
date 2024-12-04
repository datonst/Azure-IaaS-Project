variable "vnet_name" {
  description = "Name of VNet"
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR block for VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "location" {
  description = "Location of VNet"
  type        = string
}

variable "resource_group_name" {
  description = "Name of resource group"
  type        = string
}

variable "nat_subnet_name" {
  description = "Name of NAT subnet"
  type        = string
}

variable "nat_subnet_cidrs" {
  description = "CIDR block for NAT subnet"
  type        = list(string)
}

# variable "nat_private_subnet_tags" {
#   description = "Tags for NAT subnet"
#   type        = map(string)
# }

variable "db_subnet_name" {
  description = "Name of DB subnet"
  type        = string
}

variable "db_subnet_cidrs" {
  description = "CIDR block for DB subnet"
  type        = list(string)
}

# variable "db_private_subnet_tags" {
#   description = "Tags for DB subnet"
#   type        = map(string)
# }

variable "vnet_tags" {
  description = "Tags for VNet"
  type        = map(string)
}


variable "nat_gateway_id" {
  description = "ID of NAT Gateway"
  type        = string
}



