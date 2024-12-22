# Azure and AWS Provider source and version being used
resource "random_password" "AWSTunnel1ToInstance0-PSK" {
  length  = 16
  special = false

}

resource "random_password" "AWSTunnel2ToInstance0-PSK" {
  length  = 16
  special = false
}

# aws ec2 create-key-pair --key-name web-ec2-key-pair --query 'KeyMaterial' --output text > web-ec2-key-pair.pem
# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "web-ec2-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

data "http" "source_ip" {
  url = "https://ifconfig.me"
}



# module "appgw" {
#   source = "../modules/regional/application-gateway"

#   location            = local.region
#   appgw_name            = "${local.prefix}-appgw"
#   resource_group_name = module.resource_group.name
#   subnet_id           = module.web-vnet.subnets["${local.prefix}-nat-subnet"].resource_id
#   frontend_port       = 80
#   backend_port        = 80
#   sku_name = "Standard_v2"
  
# }


# resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
#   count                   = 2
#   network_interface_id    = azurerm_network_interface.nic[count.index].id
#   ip_configuration_name   = "nic-ipconfig-${count.index+1}"
#   backend_address_pool_id = var.backend_address_pool_id
# }
