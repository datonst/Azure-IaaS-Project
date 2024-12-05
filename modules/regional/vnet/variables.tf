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


variable "vnet_tags" {
  description = "Tags for VNet"
  type        = map(string)
}



variable "subnets" {
  description = "List of subnets"
  type = list(object({
    name                        = string
    address_prefixes            = list(string)
    default_outbound_access_enabled = bool
    nat_gateway = optional(object({
      id = string
    }))
    # Optional tags can be added
    tags = optional(map(string))
  }))
  default = []
}

