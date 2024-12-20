resource "azurerm_public_ip" "VNetGWpip" {
  name                = "pip-vpn-${var.prefix}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  sku               = "Standard"
}

# Create VPN Gateway and attach gateway to VNET
resource "azurerm_virtual_network_gateway" "VNetGW" {
  name                = "vpn-${var.prefix}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = var.azure_vpn_gateway_sku

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.VNetGWpip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
  }
}

# Create Local network gateway as VPN Endpoint (AWS) to configure the VPN settings
resource "azurerm_local_network_gateway" "AWSTunnel1ToInstance0" {
  name                = "lngw-${var.prefix}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  gateway_address     = var.local_gateway_address
  address_space       = [var.vnet_cidr]
}
# 
resource "azurerm_local_network_gateway" "AWSTunnel2ToInstance0" {
  name                = "lngw-standby-${var.prefix}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  gateway_address     = var.local_standby_gateway_address
  address_space       = [var.vnet_cidr]
}

# Create Site-2-Site VPN Connection between VNGW (Azure) and LNGW (AWS)
resource "azurerm_virtual_network_gateway_connection" "AWSTunnel1ToInstance0" {
  name                = "connection-${var.prefix}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VNetGW.id
  local_network_gateway_id   = azurerm_local_network_gateway.AWSTunnel1ToInstance0.id

  shared_key = var.connection_shared_key
}

resource "azurerm_virtual_network_gateway_connection" "AWSTunnel2ToInstance0" {
  name                = "connection-standby-${var.prefix}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VNetGW.id
  local_network_gateway_id   = azurerm_local_network_gateway.AWSTunnel2ToInstance0.id
  shared_key = var.connection_standby_shared_key
}




