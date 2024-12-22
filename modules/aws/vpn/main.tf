# Create Customer Gateway as VPN Endpoint to configure the VPN settings
# azurerm_public_ip.VNet1GWpip.ip_address
resource "aws_customer_gateway" "ToAzureInstance0" {
  bgp_asn    = var.azure_vpn_gateway_asn
  ip_address = var.azure_vpn_gateway_ip
  type       = "ipsec.1"

  tags = {
    Name = "cgw-${var.prefix}"
  }
}

# Create VPN Gateway and attach gateway to VPC and route table
resource "aws_vpn_gateway" "vpn-gw" {
  vpc_id            = var.vpc_id
  availability_zone = var.availability_zone
  tags = {
    Name = "vpg-${var.prefix}"
  }
}

# Add a route to send traffic from AWS to Azure
resource "aws_vpn_gateway_route_propagation" "main" {
  vpn_gateway_id = aws_vpn_gateway.vpn-gw.id
  route_table_id = var.route_table_id
}

# Create Site-2-Site VPN Connection between VPG (AWS) and CGW (Azure)
resource "aws_vpn_connection" "ToAzureInstance0" {
  vpn_gateway_id      = aws_vpn_gateway.vpn-gw.id
  customer_gateway_id = aws_customer_gateway.ToAzureInstance0.id
  type                = "ipsec.1"
  static_routes_only  = true

  tunnel1_preshared_key = var.connection_shared_key
  tunnel2_preshared_key = var.connection_standby_shared_key

  tags = {
    Name = "vpn-${var.prefix}"
  }
}

# Add a static IP prefix route between a VPN connection and a customer gateway.
# Creates a route for each subnet prefix in azure_route_prefix
resource "aws_vpn_connection_route" "office" {
  for_each = toset(var.destination_cidr_block)
  destination_cidr_block = each.value
  vpn_connection_id      = aws_vpn_connection.ToAzureInstance0.id
}