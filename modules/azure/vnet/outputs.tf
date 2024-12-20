output "name" {
  value = module.vnet.name
}

output "resource_id" {
  value = module.vnet.resource_id
}

output "subnets" {
    value = module.vnet.subnets
}

output "cidr_block" {
    value = var.vnet_cidr
}
