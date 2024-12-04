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

module "vnet" {
    source = "../modules/regional/vnet"

    location            = local.region
    vnet_name           = "${local.prefix}-vnet"
    vnet_cidr           = ["172.17.0.0/16"]
    resource_group_name = module.resource_group.name
    nat_subnet_name     = "${local.prefix}-nat-subnet"
    nat_subnet_cidrs    = ["172.17.1.0/24"]
    nat_gateway_id      = module.nat_gateway.nat_gateway_id
    db_subnet_name      = "${local.prefix}-db-subnet"
    db_subnet_cidrs     = ["172.17.64.0/24"]
    vnet_tags = local.tags
}

module "load-balancer" {
    source = "../modules/regional/load-balancer"
    location            = local.region
    lb_name             = "${local.prefix}-lb"
    resource_group_name = module.resource_group.name
    sku_name            = "Standard"
}