module "vnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  location            = var.location
  address_space       = var.vnet_cidr
  name                = var.vnet_name

  resource_group_name = var.resource_group_name
  subnets = {
    "nat_public_subnet" = {
      name             = var.nat_subnet_name
      address_prefixes = var.nat_subnet_cidrs
      default_outbound_access_enabled = true
      nat_gateway = {
        id = var.nat_gateway_id
      }
      # tags = var.nat_private_subnet_tags
    }
    "db_private_subnet" = {
      name             = var.db_subnet_name
      address_prefixes =  var.db_subnet_cidrs
      default_outbound_access_enabled = false
      # tags = var.db_private_subnet_tags
    } 
  }

}