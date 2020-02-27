output "outputs" {
  value = {
    aws_availability_zones  = data.aws_availability_zones.current
    aws_nat_gateways        = aws_nat_gateway.nat
    aws_route_table_private = aws_route_table.private
    aws_subnets_private     = aws_subnet.private
    aws_subnets_public      = aws_subnet.public
    aws_vpc                 = module.vpc.vpc
  }
}
