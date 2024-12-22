output "tunnel1_address" {
  description = "The public IP address of the first VPN tunnel"
  value = aws_vpn_connection.ToAzureInstance0.tunnel1_address
}
output "tunnel2_address" {
  description = "The public IP address of the second VPN tunnel"
  value = aws_vpn_connection.ToAzureInstance0.tunnel2_address
  
}