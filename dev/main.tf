module "resource_group" {
    source = "../modules/regional/resource-group"
    location = local.region
    name = "${local.prefix}-rg"
}

module "nat_gateway" {
  source = "../modules/regional/nat-gateway"
  nat_gateway_name        = "${local.prefix}-nat"
  location                = local.region
  resource_group_name     = module.resource_group.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

module "web-vnet" {
  source = "../modules/regional/vnet"

  location            = local.region
  vnet_name           = "${local.prefix}-vnet"
  vnet_cidr           = ["172.17.0.0/16"]
  resource_group_name = module.resource_group.name
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

#   location            = local.region
#   appgw_name            = "${local.prefix}-appgw"
#   resource_group_name = module.resource_group.name
#   subnet_id           = module.web-vnet.subnets["${local.prefix}-nat-subnet"].resource_id
#   frontend_port       = 80
#   backend_port        = 80
#   sku_name = "Standard_v2"
  
# }

module "hub-vnet" {
  source = "../modules/regional/vnet"

  location            = local.region
  vnet_name           = "${local.prefix}-hub-vnet"
  vnet_cidr           = ["10.0.0.0/16"]
  resource_group_name = module.resource_group.name
  vnet_tags           = local.tags

  subnets = [
    {
      name                        = "application-gateway-subnet"
      address_prefixes            = ["10.0.1.0/24"]
      default_outbound_access_enabled = true
    }
  ]
}

module "vm" {
  source = "../modules/regional/vm"
  subnet_id = module.web-vnet.subnets["${local.prefix}-public-subnet"].resource_id
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