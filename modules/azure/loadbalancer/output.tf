output "lb_id" {
  value = azurerm_lb.lb.id
}

output "ip_address" {
  value = var.associate_public_ip_address ? azurerm_public_ip.lb_pip[0].ip_address : azurerm_lb.lb.frontend_ip_configuration[0].private_ip_address
}

output "frontend_ip_configuration" {
  value = azurerm_lb.lb.frontend_ip_configuration[0]
}