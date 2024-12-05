output "vm_ids" {
  value = azurerm_linux_virtual_machine.vm[*].id
}

output "nic_ids" {
  value = azurerm_network_interface.nic[*].id
}

