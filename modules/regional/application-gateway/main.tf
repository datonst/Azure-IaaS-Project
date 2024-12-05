
resource "azurerm_public_ip" "appgw-pip" {
  name                = "${var.appgw_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}


resource "azurerm_application_gateway" "appgw" {
  name                = var.appgw_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku_name
    tier     = var.sku_name
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "${var.appgw_name}-my-gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name =  "${var.appgw_name}-my-frontend-port"
    port = var.frontend_port
  }

  frontend_ip_configuration {
    name                 = "${var.appgw_name}-my-frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.appgw-pip.id
  }

  backend_address_pool {
    name = "${var.appgw_name}-my-backend-pool"
  }

  backend_http_settings {
    name                  = "${var.appgw_name}-my-http-settings"
    cookie_based_affinity = "Disabled"
    # path                  = "/path1/"
    port                  = var.backend_port
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "${var.appgw_name}-my-http-listener"
    frontend_ip_configuration_name = "${var.appgw_name}-my-frontend-ip-configuration"
    frontend_port_name             = "${var.appgw_name}-my-frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${var.appgw_name}-my-request-routing-rule"
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = "${var.appgw_name}-my-http-listener"
    backend_address_pool_name  = "${var.appgw_name}-my-backend-pool"
    backend_http_settings_name = "${var.appgw_name}-my-http-settings"
  }
}