output "nat_gateway_id" {
  value = azurerm_nat_gateway.nat.id
}

output "public_ip_id" {
  value = azurerm_public_ip.public_ip.id
}