output "vm_ids" {
  value = azurerm_linux_virtual_machine.vm[*].id
}


output "network_interfaces" {
  value = azurerm_network_interface.nic[*]
}

output "network_security_group_name" {
  value = azurerm_network_security_group.nsg-vm.name
}
