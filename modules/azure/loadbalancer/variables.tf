variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Location for all resources."
}


variable "associate_public_ip_address" {
  type        = bool
  description = "Associate public IP address to the VM." 
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet."
}
variable "name" {
  type        = string
  description = "Name of the VM."
}

variable "lb_rules" {
  type        = list(object({
    protocol      = string
    frontend_port = number
    backend_port  = number
  }))
  description = "List of load balancer rules." 
}

variable "backend_pool_interfaces" {
  type        = list(object({
    network_interface_id    = string
    ip_configuration_name   = string
  }))
  description = "List of pool VM network interfaces."
}