module "vnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  location            = var.location
  address_space       = var.vnet_cidr
  name                = var.vnet_name

  resource_group_name = var.resource_group_name
  subnets = { for subnet in var.subnets : subnet.name => {
    name                        = subnet.name
    address_prefixes            = subnet.address_prefixes
    default_outbound_access_enabled = subnet.default_outbound_access_enabled
    nat_gateway = subnet.nat_gateway != null ? subnet.nat_gateway : null
    # tags = subnet.tags
  }}

}