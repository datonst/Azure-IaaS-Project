resource "azurerm_resource_group" "web_project" {
  name     = var.resource_group_name
  location = var.location
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.web_project.name
  location           = azurerm_resource_group.web_project.location
}

module "security" {
  source              = "./modules/security"
  resource_group_name = azurerm_resource_group.web_project.name
  location           = azurerm_resource_group.web_project.location
  frontend_subnet_id  = module.networking.frontend_subnet_id
  backend_subnet_id   = module.networking.backend_subnet_id
}

# module "loadbalancer" {
#   source              = "./modules/loadbalancer"
#   resource_group_name = azurerm_resource_group.web_project.name
#   location           = azurerm_resource_group.web_project.location
# }

module "frontend_vm" {
  count               = 1
  source             = "./modules/vm"
  location           = azurerm_resource_group.web_project.location
  vm_name            = "frontend-vm-${count.index}"
  resource_group_name = azurerm_resource_group.web_project.name
  subnet_id          = module.networking.frontend_subnet_id
  vm_size            = "Standard_B2s"
  os_image = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  admin_username     = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path
  public_ip_id       = azurerm_public_ip.frontend_ip[count.index].id
#   lb_backend_pool_id = module.loadbalancer.backend_pool_id
}

module "backend_vm" {
  count               = 1
  source             = "./modules/vm"
  location           = azurerm_resource_group.web_project.location
  vm_name            = "backend-vm-${count.index}"
  resource_group_name = azurerm_resource_group.web_project.name
  subnet_id          = module.networking.backend_subnet_id
  vm_size            = "Standard_B2s"
  os_image = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  admin_username     = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path
  public_ip_id       = azurerm_public_ip.backend_ip[count.index].id
}


resource "azurerm_public_ip" "frontend_ip" {
  count               = 1
  name                = "frontend-public-ip-${count.index}"
  resource_group_name = azurerm_resource_group.web_project.name
  location            = azurerm_resource_group.web_project.location
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "backend_ip" {
  count               = 1
  name                = "backend-public-ip-${count.index}"
  resource_group_name = azurerm_resource_group.web_project.name
  location            = azurerm_resource_group.web_project.location
  allocation_method   = "Static"
}


module "avm-res-network-loadbalancer" {
  source  = "Azure/avm-res-network-loadbalancer/azurerm"
  version = "0.3.2"
  location = "East Asia"
  frontend_ip_configurations = {
    # frontend_configuration_1 = {
    #     frontend_private_ip_address_version = "IPv4"
    #     frontend_private_ip_address_allocation = "Dynamic"
    # }
  }
#   backend_address_pool_addresses = {
#     address1 = {
        
#     }
#   }
  resource_group_name = azurerm_resource_group.web_project.name
  name = "lb"
}