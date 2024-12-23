resource "azurerm_public_ip" "lb_ip" {
  name                = "lb_ip"
  location           = var.location
  resource_group_name = var.resource_group_name
  allocation_method  = "Static"
  sku               = "Standard"
}

resource "azurerm_lb" "web_lb" {
  name                = "web-lb"
  location           = var.location
  resource_group_name = var.resource_group_name
  sku               = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "web_backend_pool" {
  loadbalancer_id = azurerm_lb.web_lb.id
  name           = "web-backend-pool"
}

resource "azurerm_lb_probe" "web_probe" {
  loadbalancer_id = azurerm_lb.web_lb.id
  name           = "web-probe"
  port           = 80
}

resource "azurerm_lb_rule" "web_rule" {
  loadbalancer_id               = azurerm_lb.web_lb.id
  name                         = "web-rule"
  protocol                     = "Tcp"
  frontend_port                = 80
  backend_port                 = 80
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids      = [azurerm_lb_backend_address_pool.web_backend_pool.id]
  probe_id                     = azurerm_lb_probe.web_probe.id
}