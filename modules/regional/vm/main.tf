resource "azurerm_network_interface" "nic" {
  count               = var.number_of_vm
  name                = "nic-${count.index+1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "nic-ipconfig-${count.index+1}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# resource "random_password" "password" {
#   length  = 16
#   special = true
#   lower   = true
#   upper   = true
#   numeric = true
# }

# resource "azurerm_windows_virtual_machine" "vm" {
#   count               = var.number_of_vm
#   name                = "myVM${count.index+1}"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   size                = "Standard_DS1_v2"
#   admin_username      = "azureadmin"
#   admin_password      = random_password.password.result

#   network_interface_ids = [
#     azurerm_network_interface.nic[count.index].id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }


#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2019-Datacenter"
#     version   = "latest"
#   }
# }

# resource "azurerm_virtual_machine_extension" "vm-extensions" {
#   count                = var.number_of_vm
#   name                 = "vm${count.index+1}-ext"
#   virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.10"

#   settings = <<SETTINGS
#     {
#         "commandToExecute": "powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
#     }
# SETTINGS
# }

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.number_of_vm
  name                = "myVM${count.index+1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/my-key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}