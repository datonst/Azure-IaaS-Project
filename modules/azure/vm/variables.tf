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

variable "public_key" {
  description = "Public key for SSH access"
  type        = string
}
variable "name" {
  description = "Name of the VM"
  type        = string 
}

variable "associate_public_ip_address" {
  description = "Associate public IP address with the VM"
  type        = bool
  default     = false 
}

variable "proximity_placement_group_id" {
  description = "ID of the proximity placement group"
  type        = string
  default     = null
}

variable "custom_data" {
  description = "Custom data for the VM"
  type        = string
  default     = null
}