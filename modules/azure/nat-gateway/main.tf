resource "azurerm_nat_gateway" "nat" {
  name                    = var.nat_gateway_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = var.sku_name
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  zones                   = var.zones
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.nat_gateway_name}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.allocation_method
  sku                 = var.sku_name
  zones               = var.zones # Public IP must be in the same zone as the NAT Gateway
}


resource "azurerm_nat_gateway_public_ip_association" "nat_public_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.public_ip.id
}