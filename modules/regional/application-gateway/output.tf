output "name" {
  value = azurerm_application_gateway.appgw.name
}



output "appgw_id" {
  value = azurerm_application_gateway.appgw.id
  
}
output "backend_address_pool_id" {
  value = one(azurerm_application_gateway.appgw.backend_address_pool).id
}