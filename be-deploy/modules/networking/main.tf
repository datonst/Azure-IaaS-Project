resource "azurerm_virtual_network" "web_vpc" {
  name                = "web-vpc"
  address_space       = ["10.0.0.0/16"]
  location           = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "backend" {
  name                 = "backend-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.web_vpc.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "frontend-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.web_vpc.name
  address_prefixes     = ["10.0.2.0/24"]
}