resource "azurerm_network_security_group" "nsg_vm" {
  name                = "nsg-vm-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "ssh_rule" {
  name                        = "ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_vm.name
}

resource "azurerm_network_security_rule" "icmp_rule" {
  name                        = "icmp"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_vm.name
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss" {
  name                        = "${var.name}-vmss"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  platform_fault_domain_count = 1
  sku_name                    = "Standard_B1s"
  instances                   = var.number_of_vm
  zones                       = ["1"]
  extension_operations_enabled = true

  os_profile {
    linux_configuration {
      admin_username                 = "adminuser"
      admin_password                 = "Admin+123456"
      disable_password_authentication = false

      admin_ssh_key {
        username   = "adminuser"
        public_key = var.public_key
      }
    }
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  network_interface {
    name                      = "nic-${var.name}"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.nsg_vm.id
    ip_configuration {
      name                          = "ip-${var.name}"
      primary                       = true
      subnet_id                     = var.subnet_id
    }
  }
}
