module "web_resource_group" {
  source   = "../modules/azure/resource-group"
  location = local.azure_region
  name     = "${local.prefix}-web-rg"
}




module "nat_gateway" {
  source                  = "../modules/azure/nat-gateway"
  nat_gateway_name        = "${local.prefix}-nat"
  location                = local.azure_region
  resource_group_name     = module.web_resource_group.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

module "web_vnet" {
  source = "../modules/azure/vnet"

  location            = local.azure_region
  vnet_name           = "${local.prefix}-vnet"
  vnet_cidr           = ["172.17.0.0/16"]
  resource_group_name = module.web_resource_group.name
  vnet_tags           = local.tags

  subnets = [
    {
      name                        = "${local.prefix}-nat-subnet"
      address_prefixes            = ["172.17.1.0/24"]
      default_outbound_access_enabled = true
      nat_gateway = {
        id = module.nat_gateway.nat_gateway_id
      }
    },
    {
      name                        = "${local.prefix}-public-subnet"
      address_prefixes            = ["172.17.2.0/24"]
      default_outbound_access_enabled = true
    },
    {
      name                        = "${local.prefix}-db-subnet"
      address_prefixes            = ["172.17.64.0/24"]
      default_outbound_access_enabled = false
    }
  ]
}

# module "appgw" {
#   source = "../modules/regional/application-gateway"

#   location            = local.azure_region
#   appgw_name            = "${local.prefix}-appgw"
#   resource_group_name = module.resource_group.name
#   subnet_id           = module.web_vnet.subnets["${local.prefix}-nat-subnet"].resource_id
#   frontend_port       = 80
#   backend_port        = 80
#   sku_name = "Standard_v2"

# }




module "frontend_vm" {
  name = "frontend"
  source              = "../modules/azure/vm"
  subnet_id           = module.web_vnet.subnets["${local.prefix}-public-subnet"].resource_id
  location            = local.azure_region
  resource_group_name = module.web_resource_group.name
  number_of_vm        = 1
  public_key = tls_private_key.key_pair.public_key_openssh
  associate_public_ip_address = false
}


# resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
#   count                   = 2
#   network_interface_id    = azurerm_network_interface.nic[count.index].id
#   ip_configuration_name   = "nic-ipconfig-${count.index+1}"
#   backend_address_pool_id = var.backend_address_pool_id
# }


##################### HUB AZURE ############################
module "hub_resource_group" {
  source   = "../modules/azure/resource-group"
  location = local.azure_region
  name     = "${local.prefix}-hub-rg"
}

module "hub_vnet" {
  source = "../modules/azure/vnet"

  location            = local.azure_region
  vnet_name           = "${local.prefix}-hub-vnet"
  vnet_cidr           = local.azure_hub_vnet_cidr
  resource_group_name = module.hub_resource_group.name
  vnet_tags           = local.tags

  subnets = [
    {
      name                            = "application-gateway-subnet"
      address_prefixes                = ["192.168.1.0/24"]
      default_outbound_access_enabled = true
    },
    {
      name                            = "GatewaySubnet"
      address_prefixes                = ["192.168.2.0/24"]
      default_outbound_access_enabled = true
    },
    {
      name                            = "test-subnet"
      address_prefixes                = ["192.168.3.0/24"]
      default_outbound_access_enabled = true
    }
  ]
}

resource "azurerm_virtual_network_peering" "hub-to-web" {
  name                      = "peerhubtoweb"
  resource_group_name       = module.hub_resource_group.name
  virtual_network_name      = module.hub_vnet.name
  remote_virtual_network_id = module.web_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "web-to-hub" {
  name                      = "perwebtohub"
  resource_group_name       = module.web_resource_group.name
  virtual_network_name      = module.web_vnet.name
  remote_virtual_network_id = module.hub_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit = true
}
################ CONNECT AZURE TO AWS ####################

resource "azurerm_public_ip" "VNetGWpip" {
  name                = "pip-vpn-${local.prefix}"
  location            =  module.hub_resource_group.location
  resource_group_name = module.hub_resource_group.name
  allocation_method = "Static"
  sku               = "Standard"
}

module "azure_vpn" {
  source                  = "../modules/azure/vpn"
  prefix                  = local.prefix
  azure_vpn_gateway_sku   = "VpnGw1"
  resource_group_name     = module.hub_resource_group.name
  resource_group_location = module.hub_resource_group.location

  VNetGWpip_id = azurerm_public_ip.VNetGWpip.id
  subnet_id = module.hub_vnet.subnets["GatewaySubnet"].resource_id

  destination_cidr_block        = local.azure_destination_cidr_block
  local_gateway_address         = module.aws_vpn.tunnel1_address
  local_standby_gateway_address = module.aws_vpn.tunnel2_address

  connection_shared_key         = random_password.AWSTunnel1ToInstance0-PSK.result
  connection_standby_shared_key = random_password.AWSTunnel2ToInstance0-PSK.result
}


module "hub-vm" {
  source              = "../modules/azure/vm"
  name                = "hub-vm"
  subnet_id           = module.hub_vnet.subnets["test-subnet"].resource_id
  location            = local.azure_region
  resource_group_name = module.hub_resource_group.name
  number_of_vm        = 1
  public_key = tls_private_key.key_pair.public_key_openssh
  associate_public_ip_address = true
}


######################### VM AZURE ############################




