resource "azurerm_linux_virtual_machine" "vm" {
  name = var.vm_name
  resource_group_name = var.resource_group_name
  location = var.location
  size = var.vm_size
  admin_username = var.admin_username
  
  disable_password_authentication = true
  
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }


  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.os_image.publisher
    offer = var.os_image.offer
    sku = var.os_image.sku
    version = var.os_image.version 
  } 
}

resource "azurerm_network_interface" "nic" {
  name = "${var.vm_name}-nic"
  location = var.location
  resource_group_name = var.resource_group_name
  ip_configuration { 
    name = "internal" 
    subnet_id = var.subnet_id
    private_ip_address_allocation = "Dynamic" 

    public_ip_address_id = var.public_ip_id
  }
}




