locals {
  aws_region = "us-east-1"
  azure_hub_region = "East Asia"
  azure_spoke_region = "Korea Central"
  prefix = "dev-bigteam"
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

  aws_vpc_cidr_block = "10.10.0.0/16"
  azure_hub_vnet_cidr= ["192.168.0.0/16"]

  aws_availability_zone = "us-east-1a"

  azure_vpn_gateway_asn = "65000" 

  # đây là những prefix mà aws cho phép kết nối qua route table
  aws_destination_cidr_block = ["192.168.3.0/24","172.17.0.0/16"]
# đây là những prefix mà azure cho phép kết nối qua Local Network Gateway
  azure_destination_cidr_block= ["10.10.0.0/16"]
  
  
}

