output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_id" {
  value = aws_subnet.vpn-subnet.id
}

output "route_table_id" {
  value = aws_route_table.vpn-route-table.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}






