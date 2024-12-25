resource "azurerm_network_security_group" "nsg-vm" {
  name                = "nsg-vm-t-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_public_ip" "my_terraform_public_ip" {
  count               = var.associate_public_ip_address ? 1 : 0
  name                = "${var.name}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  lifecycle {
      create_before_destroy = true
  }
}

resource "azurerm_network_interface" "nic" {
  count               = var.number_of_vm
  name                = "nic-${var.name}-${count.index+1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "nic-ipconfig-${var.name}-${count.index+1}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.associate_public_ip_address ? azurerm_public_ip.my_terraform_public_ip[count.index].id : null
  }
}

resource "azurerm_network_security_rule" "allow-internet-outbound" {
  name                        = "AllowInternetOutbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-vm.name
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
  name                = "${var.name}-${count.index+1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Admin+123456"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]
  
  admin_ssh_key {
    username   = "adminuser"
    # public_key = file("~/.ssh/my-key.pub")
    public_key = var.public_key
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

  custom_data = var.custom_data != null ? var.custom_data : null
  depends_on = [ azurerm_network_interface.nic ]
}

resource "azurerm_network_security_rule" "nsg-ssh-vm-rule" {
  name                        = "ssh"
  description                 = "Allow SSH."
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*" #"${data.http.source_ip.response_body}/32"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-vm.name
}

resource "azurerm_network_security_rule" "nsg-aws-vm-rule" {
  name                        = "icmp"
  description                 = "Allow ICMP for AWS VPC resources"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       =  "*" #aws_vpc.aws-vpc.cidr_block
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-vm.name
}

resource "azurerm_network_interface_security_group_association" "vm-sg-asoc" {
  count                     = var.number_of_vm
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg-vm.id
}

