
############### RESOURCE GROUPS ####################
module "hub_resource_group" {
  source   = "../modules/azure/resource-group"
  location = local.azure_hub_region
  name     = "${local.prefix}-hub-rg"
}

module "spoke_resource_group" {
  source   = "../modules/azure/resource-group"
  location = local.azure_spoke_region
  name     = "${local.prefix}-spoke-rg"
}
################ Proximity Placement Group ############################
resource "azurerm_proximity_placement_group" "proximity_placement_group" {
  name                = "${local.prefix}-PlacementGroup"
  location            = local.azure_spoke_region
  resource_group_name = module.spoke_resource_group.name
  tags = local.tags
}


################### VNETS ####################
module "hub_vnet" {
  source = "../modules/azure/vnet"

  location            = local.azure_hub_region
  vnet_name           = "${local.prefix}-hub-vnet"
  vnet_cidr           = local.azure_hub_vnet_cidr
  resource_group_name = module.hub_resource_group.name
  vnet_tags           = local.tags

  subnets = [
    {
      name                            = "AzureFirewallSubnet"
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
    },
    {
      name                            = "AzureBastionSubnet"
      address_prefixes                = ["192.168.4.0/26"]
      default_outbound_access_enabled = true
    }
  ]
}

module "spoke_vnet" {
  source = "../modules/azure/vnet"

  location            = local.azure_spoke_region
  vnet_name           = "${local.prefix}-spoke-vnet"
  vnet_cidr           = ["172.17.0.0/16"]
  resource_group_name = module.spoke_resource_group.name
  vnet_tags           = local.tags

  subnets = [
    {
      name                        = "${local.prefix}-lb-subnet"
      address_prefixes            = ["172.17.1.0/24"]
      default_outbound_access_enabled = true
      # nat_gateway = {
      #   id = module.nat_gateway.nat_gateway_id
      # }
    },
    {
      name                        = "${local.prefix}-public-subnet"
      address_prefixes            = ["172.17.2.0/24"]
      default_outbound_access_enabled = true
    },
    {
      name                        = "${local.prefix}-private-subnet"
      address_prefixes            = ["172.17.64.0/24"]
      default_outbound_access_enabled = true
    }
  ]
}


##########################CONNECT AZURE TO AWS ####################

resource "azurerm_public_ip" "VNetGWpip" {
  name                = "pip-vpn-${local.prefix}"
  location            =  local.azure_hub_region
  resource_group_name = module.hub_resource_group.name
  allocation_method = "Static"
  sku               = "Standard"
}

module "azure_vpn" {
  source                  = "../modules/azure/vpn"
  prefix                  = local.prefix
  azure_vpn_gateway_sku   = "VpnGw1"
  resource_group_name     = module.hub_resource_group.name
  resource_group_location = local.azure_hub_region

  VNetGWpip_id = azurerm_public_ip.VNetGWpip.id
  subnet_id = module.hub_vnet.subnets["GatewaySubnet"].resource_id

  destination_cidr_block        = local.azure_destination_cidr_block
  local_gateway_address         = module.aws_vpn.tunnel1_address
  local_standby_gateway_address = module.aws_vpn.tunnel2_address

  connection_shared_key         = random_password.AWSTunnel1ToInstance0-PSK.result
  connection_standby_shared_key = random_password.AWSTunnel2ToInstance0-PSK.result
}

##################### VNET PEERING ############################

resource "azurerm_virtual_network_peering" "hub-to-web" {
  name                      = "peerhubtoweb"
  resource_group_name       = module.hub_resource_group.name
  virtual_network_name      = module.hub_vnet.name
  remote_virtual_network_id = module.spoke_vnet.resource_id
  allow_virtual_network_access = true
  allow_gateway_transit = true

  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "web-to-hub" {
  name                      = "perwebtohub"
  resource_group_name       = module.spoke_resource_group.name
  virtual_network_name      = module.spoke_vnet.name
  remote_virtual_network_id = module.hub_vnet.resource_id
  allow_virtual_network_access = true
  allow_gateway_transit = true

  use_remote_gateways = true
}

######################### VM AZURE ############################

module "backend_vm" {
  source              = "../modules/azure/vm"
  name                = "backend-vm"
  subnet_id           = module.spoke_vnet.subnets["${local.prefix}-private-subnet"].resource_id
  location            = local.azure_spoke_region
  resource_group_name = module.spoke_resource_group.name
  proximity_placement_group_id = azurerm_proximity_placement_group.proximity_placement_group.id
  number_of_vm        = 1
  public_key = tls_private_key.key_pair.public_key_openssh
  associate_public_ip_address = false
}

module "frontend_vm" {
  name = "frontend-vm"
  source              = "../modules/azure/vm"
  subnet_id           = module.spoke_vnet.subnets["${local.prefix}-public-subnet"].resource_id
  location            = local.azure_spoke_region
  resource_group_name = module.spoke_resource_group.name
  proximity_placement_group_id = azurerm_proximity_placement_group.proximity_placement_group.id
  number_of_vm        = 1
  public_key = tls_private_key.key_pair.public_key_openssh
  associate_public_ip_address = false
  custom_data = base64encode(<<EOF
#!/bin/bash
echo "LOAD_BALANCER_IP=${module.internal_lb.ip_address}" >> /etc/environment
EOF
)
}





######################## LOAD BALANCER ############################

resource "azurerm_network_security_rule" "nsg-http-for-frontend" {
  name                        = "nsg-http-for-frontend"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.spoke_resource_group.name
  network_security_group_name = module.frontend_vm.network_security_group_name
}


resource "azurerm_network_security_rule" "allow-frontend-port" {
  name                        = "allow-frontend-port"
  priority                    = 106
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.spoke_resource_group.name
  network_security_group_name = module.backend_vm.network_security_group_name
}



module "internal_lb" {
  name = "internal"
  source = "../modules/azure/loadbalancer"
  location = local.azure_spoke_region
  resource_group_name = module.spoke_resource_group.name
  associate_public_ip_address = false
  subnet_id = module.spoke_vnet.subnets["${local.prefix}-lb-subnet"].resource_id
  lb_rules = [
    {
      protocol      = "Tcp"
      frontend_port = 8080
      backend_port  = 8080
    }
  ]
  backend_pool_interfaces = [
    {
      network_interface_id    = module.backend_vm.network_interfaces[0].id
      ip_configuration_name   = module.backend_vm.network_interfaces[0].ip_configuration[0].name
    }
  ]
}

module "lb" {
  name = "lb"
  source = "../modules/azure/loadbalancer"
  location = local.azure_spoke_region
  resource_group_name = module.spoke_resource_group.name
  associate_public_ip_address = true
  subnet_id = module.spoke_vnet.subnets["${local.prefix}-lb-subnet"].resource_id
  lb_rules = [
    {
      protocol      = "Tcp"
      frontend_port = 80
      backend_port  = 80
    }
  ]
  backend_pool_interfaces = [
    {
      network_interface_id    = module.frontend_vm.network_interfaces[0].id
      ip_configuration_name   = module.frontend_vm.network_interfaces[0].ip_configuration[0].name
    }
  ]

}


######################### FIREWALL ############################
module "azure_firewall" {
  source = "../modules/azure/firewall"
  location = local.azure_hub_region
  resource_group_name =  module.hub_resource_group.name
  subnet_id = module.hub_vnet.subnets["AzureFirewallSubnet"].resource_id
  lb_public_ip = module.lb.ip_address
}

######################### BASTION ############################
resource "azurerm_public_ip" "BastionPip" {
  name                = "${local.prefix}-bastion-pip"
  location            =  local.azure_hub_region
  resource_group_name = module.hub_resource_group.name
  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${local.prefix}-bastion"
  location            = local.azure_hub_region
  resource_group_name = module.hub_resource_group.name

  ip_configuration {
    name                 = "bastion-ip-configuration"
    subnet_id            = module.hub_vnet.subnets["AzureBastionSubnet"].resource_id
    public_ip_address_id = azurerm_public_ip.BastionPip.id
  }
}
