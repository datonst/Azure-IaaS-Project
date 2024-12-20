############################################################
###########################AZURE######################


module "resource_group" {
    source = "../modules/azure/resource-group"
    location = local.region
    name = "${local.prefix}-rg"
}

module "hub_resource_group" {
    source = "../modules/azure/resource-group"
    location = local.region
    name = "${local.prefix}-hub-rg"
}



module "nat_gateway" {
  source = "../modules/azure/nat-gateway"
  nat_gateway_name        = "${local.prefix}-nat"
  location                = local.region
  resource_group_name     = module.resource_group.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

# module "web_vnet" {
#   source = "../modules/azure/vnet"

#   location            = local.region
#   vnet_name           = "${local.prefix}-vnet"
#   vnet_cidr           = ["172.17.0.0/16"]
#   resource_group_name = module.resource_group.name
#   vnet_tags           = local.tags

#   subnets = [
#     {
#       name                        = "${local.prefix}-nat-subnet"
#       address_prefixes            = ["172.17.1.0/24"]
#       default_outbound_access_enabled = true
#       nat_gateway = {
#         id = module.nat_gateway.nat_gateway_id
#       }
#     },
#     {
#       name                        = "${local.prefix}-public-subnet"
#       address_prefixes            = ["172.17.2.0/24"]
#       default_outbound_access_enabled = true
#     },
#     {
#       name                        = "${local.prefix}-db-subnet"
#       address_prefixes            = ["172.17.64.0/24"]
#       default_outbound_access_enabled = false
#     }
#   ]
# }

# module "appgw" {
#   source = "../modules/regional/application-gateway"

#   location            = local.region
#   appgw_name            = "${local.prefix}-appgw"
#   resource_group_name = module.resource_group.name
#   subnet_id           = module.web_vnet.subnets["${local.prefix}-nat-subnet"].resource_id
#   frontend_port       = 80
#   backend_port        = 80
#   sku_name = "Standard_v2"
  
# }



module "hub_vnet" {
  source = "../modules/azure/vnet"

  location            = local.region
  vnet_name           = "${local.prefix}-hub-vnet"
  vnet_cidr           = ["192.168.0.0/16"]
  resource_group_name = module.hub_resource_group.name
  vnet_tags           = local.tags

  subnets = [
    {
      name                        = "application-gateway-subnet"
      address_prefixes            = ["192.168.1.0/24"]
      default_outbound_access_enabled = true
    },
    {
      name                        = "vpn-subnet"
      address_prefixes            = ["192.168.2.0/24"]
      default_outbound_access_enabled = true
    }
  ]
}

module "vm" {
  source = "../modules/azure/vm"
  subnet_id = module.web_vnet.subnets["${local.prefix}-public-subnet"].resource_id
  location = local.region
  resource_group_name = module.resource_group.name
  number_of_vm = 2
}

# resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
#   count                   = 2
#   network_interface_id    = azurerm_network_interface.nic[count.index].id
#   ip_configuration_name   = "nic-ipconfig-${count.index+1}"
#   backend_address_pool_id = var.backend_address_pool_id
# }

################ CONNECT AZURE TO AWS ####################
module "vpn" {
  source = "../modules/azure/vpn"
  prefix = local.prefix
  azure_vpn_gateway_sku = "VpnGw1"
  resource_group_name = module.hub_resource_group.name
  resource_group_location = module.hub_resource_group.location

  subnet_id = module.hub_vnet.subnets["vpn-subnet"].resource_id
  vnet_cidr = module.hub_vnet.cidr_block

  local_gateway_address = aws_vpn_connection.ToAzureInstance0.tunnel1_address
  local_standby_gateway_address = aws_vpn_connection.ToAzureInstance0.tunnel2_address
  
  connection_shared_key = random_password.AWSTunnel1ToInstance0-PSK.result
  connection_standby_shared_key = random_password.AWSTunnel2ToInstance0-PSK.result
}