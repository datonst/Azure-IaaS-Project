# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "vpc-${var.prefix}"
  }
}

# Create Internet gateway and attach gateway to VPC to let EC2 instances access the internet
resource "aws_internet_gateway" "igw-vpn" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-vpn-${var.prefix}"
  }
}

# Create Subnet and attach subnet to route table
resource "aws_subnet" "vpn-subnet" {
  count             = length(var.aws_subnet_prefixes)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.aws_subnet_prefixes[count.index]
  availability_zone = var.availability_zone
  # map_public_ip_on_launch = true

  tags = {
    Name = "subnet-vpn-${var.prefix}-${count.index + 1}"
  }
}

resource "aws_route_table" "vpn-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpn.id
  }

  tags = {
    Name = "vpn-route-table"
  }
}

resource "aws_route_table_association" "vpn-route-table-asoc" {
  count          = length(var.aws_subnet_prefixes)
  subnet_id      = aws_subnet.vpn-subnet[count.index].id
  route_table_id = aws_route_table.vpn-route-table.id
}