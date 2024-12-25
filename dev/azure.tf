module "spoke_resource_group" {
  source   = "../modules/azure/resource-group"
  location = local.azure_spoke_region
  name     = "${local.prefix}-spoke-rg"
}

module "hub_resource_group" {
  source   = "../modules/azure/resource-group"
  location = local.azure_hub_region
  name     = "${local.prefix}-hub-rg"
}


# module "nat_gateway" {
#   source                  = "../modules/azure/nat-gateway"
#   nat_gateway_name        = "${local.prefix}-nat"
#   location                = module.spoke_resource_group.location
#   resource_group_name     = module.spoke_resource_group.name
#   sku_name                = "Standard"
#   idle_timeout_in_minutes = 10
# }

module "spoke_vnet" {
  source = "../modules/azure/vnet"

  location            = module.spoke_resource_group.location
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
  depends_on = [ module.spoke_resource_group ]
}

# module "appgw" {
#   source = "../modules/regional/application-gateway"

#   location            = module.spoke_resource_group.location
#   appgw_name            = "${local.prefix}-appgw"
#   resource_group_name = module.resource_group.name
#   subnet_id           = module.spoke_vnet.subnets["${local.prefix}-nat-subnet"].resource_id
#   frontend_port       = 80
#   backend_port        = 80
#   sku_name = "Standard_v2"

# }






# resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
#   count                   = 2
#   network_interface_id    = azurerm_network_interface.nic[count.index].id
#   ip_configuration_name   = "nic-ipconfig-${count.index+1}"
#   backend_address_pool_id = var.backend_address_pool_id
# }


##################### HUB AZURE ############################


module "hub_vnet" {
  source = "../modules/azure/vnet"

  location            = module.hub_resource_group.location
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
    }
  ]
  depends_on = [ module.hub_resource_group ]
}

# resource "azurerm_virtual_network_peering" "hub-to-web" {
#   name                      = "peerhubtoweb"
#   resource_group_name       = module.hub_resource_group.name
#   virtual_network_name      = module.hub_vnet.name
#   remote_virtual_network_id = module.spoke_vnet.resource_id
#   allow_virtual_network_access = true
#   allow_gateway_transit = true

#   allow_forwarded_traffic = true
# }

# resource "azurerm_virtual_network_peering" "web-to-hub" {
#   name                      = "perwebtohub"
#   resource_group_name       = module.spoke_resource_group.name
#   virtual_network_name      = module.spoke_vnet.name
#   remote_virtual_network_id = module.hub_vnet.resource_id
#   allow_virtual_network_access = true
#   allow_gateway_transit = true

#   use_remote_gateways = true
# }


############################# delete that #####################33333
# # Route table for vnet2
# resource "azurerm_route_table" "rt_web" {
#   name                = "rt-web"
#   location            = module.spoke_resource_group.location
#   resource_group_name = module.spoke_resource_group.name
# }

# # Route for on-premise traffic
# resource "azurerm_route" "aws_route" {
#   name                   = "AwsRoute"
#   resource_group_name    = module.spoke_resource_group.name
#   route_table_name       = azurerm_route_table.rt_web.name
#   address_prefix         =  module.aws_vpc.vpc_cidr_block # Example: "10.0.0.0/16"
#   next_hop_type         = "VirtualNetworkGateway"
# }

# Associate route table with vnet2 subnet


# resource "azurerm_subnet_route_table_association" "spoke_rt_association" {
#   subnet_id      = module.spoke_vnet.subnets["${local.prefix}-public-subnet"].resource_id
#   route_table_id = azurerm_route_table.rt_web.id
# }

####################################################CONNECT AZURE TO AWS ####################

# resource "azurerm_public_ip" "VNetGWpip" {
#   name                = "pip-vpn-${local.prefix}"
#   location            =  module.hub_resource_group.location
#   resource_group_name = module.hub_resource_group.name
#   allocation_method = "Static"
#   sku               = "Standard"
# }

# module "azure_vpn" {
#   source                  = "../modules/azure/vpn"
#   prefix                  = local.prefix
#   azure_vpn_gateway_sku   = "VpnGw1"
#   resource_group_name     = module.hub_resource_group.name
#   resource_group_location = module.hub_resource_group.location

#   VNetGWpip_id = azurerm_public_ip.VNetGWpip.id
#   subnet_id = module.hub_vnet.subnets["GatewaySubnet"].resource_id

#   destination_cidr_block        = local.azure_destination_cidr_block
#   local_gateway_address         = module.aws_vpn.tunnel1_address
#   local_standby_gateway_address = module.aws_vpn.tunnel2_address

#   connection_shared_key         = random_password.AWSTunnel1ToInstance0-PSK.result
#   connection_standby_shared_key = random_password.AWSTunnel2ToInstance0-PSK.result
# }


module "lb" {
  name = "lb"
  source = "../modules/azure/loadbalancer"
  location = module.spoke_resource_group.location
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
  depends_on = [ module.spoke_resource_group ]
}


# module "azure_firewall" {
#   source = "../modules/azure/firewall"
#   location = module.spoke_resource_group.location
#   resource_group_name =  module.hub_resource_group.name
#   subnet_id = module.hub_vnet.subnets["AzureFirewallSubnet"].resource_id
#   frontend_ip_configuration = module.loadbalancer.azurerm_lb.frontend_ip_configuration
#   lb_public_ip = module.loadbalancer.azurerm_public_ip.frontend_configuration_1.ip_address
# }




######################## delete that ############################
# module "hub-vm" {
#   source              = "../modules/azure/vm"
#   name                = "hub-vm"
#   subnet_id           = module.hub_vnet.subnets["test-subnet"].resource_id
#   location            = module.spoke_resource_group.location
#   resource_group_name = module.hub_resource_group.name
#   number_of_vm        = 1
#   public_key = tls_private_key.key_pair.public_key_openssh
#   associate_public_ip_address = true
# }


######################### VM AZURE ############################

module "backend_vm" {
  source              = "../modules/azure/vm"
  name                = "backend-vm"
  subnet_id           = module.spoke_vnet.subnets["${local.prefix}-private-subnet"].resource_id
  location            = module.spoke_resource_group.location
  resource_group_name = module.spoke_resource_group.name
  number_of_vm        = 1
  public_key = tls_private_key.key_pair.public_key_openssh
  associate_public_ip_address = false
  depends_on = [ module.spoke_resource_group ]
}

module "frontend_vm" {
  name = "frontend-vm"
  source              = "../modules/azure/vm"
  subnet_id           = module.spoke_vnet.subnets["${local.prefix}-public-subnet"].resource_id
  location            = module.spoke_resource_group.location
  resource_group_name = module.spoke_resource_group.name
  number_of_vm        = 1
  public_key = tls_private_key.key_pair.public_key_openssh
  associate_public_ip_address = true
  custom_data = base64encode(<<EOF
#!/bin/bash
echo "LOAD_BALANCER_IP=${module.internal_lb.ip_address}" >> /etc/environment
EOF
)
  depends_on = [ module.spoke_resource_group ]
}


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
  depends_on = [ module.spoke_resource_group, module.frontend_vm ]
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
  depends_on = [ module.spoke_resource_group, module.backend_vm ]
}

module "internal_lb" {
  name = "internal"
  source = "../modules/azure/loadbalancer"
  location = module.spoke_resource_group.location
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
  depends_on = [ module.spoke_resource_group ]
}



