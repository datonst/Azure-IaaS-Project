output "network_interface_id" {
  value = azurerm_network_interface.nic.id
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}

output "private_ip_address" {
  value = azurerm_network_interface.nic.private_ip_address
}
