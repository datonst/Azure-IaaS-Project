output "vm_ids" {
  value = azurerm_windows_virtual_machine.vm[*].id
}

output "nic_ids" {
  value = azurerm_network_interface.nic[*].id
}

