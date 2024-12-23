variable "vm_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "vm_size" {}
variable "subnet_id" {}
variable "os_image" {
  type = object({
    publisher = string
    offer = string
    sku = string
    version = string
  })
}
variable "admin_username" {}
variable "ssh_public_key_path" {
  description = "Path to the public SSH key"
  type = string
}
variable "public_ip_id" {
  description = "The ID of the public IP to associate with the NIC"
  type = string
}
variable "lb_backend_pool_id" {
  description = "The ID of the load balancer backend address pool"
  type = string
  default = null
}