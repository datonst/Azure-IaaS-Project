variable "location" {
  description = "Location of the NAT Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID of the NAT Gateway"
  type        = string
}

variable "number_of_vm" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
}