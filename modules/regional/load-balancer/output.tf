output "lb_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}
output "lb_id" {
  value = azurerm_lb.lb.id
}
