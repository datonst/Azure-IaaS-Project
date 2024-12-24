# Tạo Public IP cho Load Balancer
resource "azurerm_public_ip" "lb_pip" {
  count               = var.associate_public_ip_address ? 1 : 0
  name                = "${var.name}-lb-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Tạo Load Balancer
resource "azurerm_lb" "lb" {
  name                = "lb-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "${var.name}-frontend"
    public_ip_address_id          = var.associate_public_ip_address ? azurerm_public_ip.lb_pip[0].id : null
    private_ip_address_allocation = var.associate_public_ip_address ? null : "Dynamic"
    subnet_id                     = var.associate_public_ip_address ? null : var.subnet_id
  }
}

# Tạo Backend Pool cho Load Balancer
resource "azurerm_lb_backend_address_pool" "backend_lb_pool" {
  name                = "${var.name}-backend-pool"
  loadbalancer_id     = azurerm_lb.lb.id
}

# Tạo Load Balancer Rule
resource "azurerm_lb_rule" "lb_rules" {
  count                          = length(var.lb_rules)
  name                           = "lb-rule-${var.name}-${count.index}"
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  protocol                       = var.lb_rules[count.index].protocol
  frontend_port                  = var.lb_rules[count.index].frontend_port
  backend_port                   = var.lb_rules[count.index].backend_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_lb_pool.id]
}


resource "azurerm_network_interface_backend_address_pool_association" "backend" {
  count                    = length(var.backend_pool_interfaces)
  network_interface_id     = var.backend_pool_interfaces[count.index].network_interface_id
  ip_configuration_name    = var.backend_pool_interfaces[count.index].ip_configuration_name
  backend_address_pool_id  = azurerm_lb_backend_address_pool.backend_lb_pool.id
}
