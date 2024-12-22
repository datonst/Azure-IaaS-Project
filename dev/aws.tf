provider "aws" {
  region = local.aws_region
}

# Create VPC
module "aws_vpc" {
  source = "../modules/aws/vpc"
  prefix = local.prefix
  vpc_cidr = local.aws_vpc_cidr_block
  aws_subnet_prefixes = ["10.10.1.0/24"]
  availability_zone = local.aws_availability_zone
}


module "aws_vpn" {
  source = "../modules/aws/vpn"
  prefix = local.prefix
  vpc_id = module.aws_vpc.vpc_id
  route_table_id = module.aws_vpc.route_table_id
  availability_zone = local.aws_availability_zone
  destination_cidr_block = local.aws_destination_cidr_block

  azure_vpn_gateway_asn = local.azure_vpn_gateway_asn
  azure_vpn_gateway_ip = azurerm_public_ip.VNetGWpip.ip_address


  connection_shared_key = random_password.AWSTunnel1ToInstance0-PSK.result
  connection_standby_shared_key = random_password.AWSTunnel2ToInstance0-PSK.result
}

# Security Groups
module "security_group_ec2" {
  source  = "../modules/aws/security-groups"
  vpc_id  = module.aws_vpc.vpc_id
  sg_name = "SG-EC2-JumpHost"
  ingress_rules = [{
    "cidr_blocks" : ["0.0.0.0/0"],
    "from_port" : 22,
    "to_port" : 22,
    "protocol" : "tcp"
    },
    {
      "cidr_blocks" : ["0.0.0.0/0"],
      "from_port" : -1,
      "to_port" : -1,
      "protocol" : "icmp"
    }
  ]

  egress_rules = [{
    "cidr_blocks" : ["0.0.0.0/0"],
    "from_port" : 0,
    "to_port" : 0,
    "protocol" : "-1"
  }]

}

module "ec2-private" {
  source                      = "../modules/aws/ec2/"
  name                        = "${local.prefix}-jumphost"
  ami_id                      = "ami-00d321eaa8a8a4640"
  instance_type               = ["t3.micro"]
  key_name                    = aws_key_pair.key_pair.key_name
#   user_data                   = <<EOF
# #!/bin/bash
# wget https://git.io/vpn -O openvpn-install.sh && bash openvpn-install.sh
# EOF
  subnet_id                   = module.aws_vpc.subnet_id
  vpc_id                      = module.aws_vpc.vpc_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [module.security_group_ec2.security_group_id]

  volume_size = ["30"]
  common_tags = local.tags
}


