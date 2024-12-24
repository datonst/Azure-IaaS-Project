
resource "azurerm_public_ip" "pip" {
  name                = "firewall-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
# Tạo Azure Firewall
resource "azurerm_firewall" "firewall" {
  name                = "az-firewall"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name      = "configuration"
    subnet_id = var.subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Tạo NAT Rule trong Azure Firewall để chuyển tiếp lưu lượng đến Load Balancer
resource "azurerm_firewall_nat_rule_collection" "nat_rule_collection" {
  name                = "RDP_NAT-to_LB"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Dnat"

  rule {
    name                  = "az-nat-rule"
    protocols             = ["TCP"]
    source_addresses      = ["*"]
    destination_addresses = [azurerm_public_ip.pip.ip_address]
    destination_ports     = ["80"]
    translated_address    = var.lb_public_ip
    translated_port       = "80"
  }
}

# Cập nhật bảng định tuyến để chuyển lưu lượng qua Azure Firewall
resource "azurerm_route_table" "route_table" {
  name                = "azure-fw-route-table"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = "DG_Route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }
  route {
    name                   = "FW_Host_Route"
    address_prefix         = "${azurerm_public_ip.pip.ip_address}/32"
    next_hop_type          = "Internet"
  }
}

# Liên kết bảng định tuyến với subnet
# resource "azurerm_subnet_route_table_association" "example" {
#   subnet_id      = var.subnet_id
#   route_table_id = azurerm_route_table.route_table.id
# }
