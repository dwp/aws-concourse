output "outputs" {
  value = {
    aws_availability_zones     = data.aws_availability_zones.current
    aws_nat_gateways           = aws_nat_gateway.nat
    aws_route_table_private    = aws_route_table.private
    aws_subnets_private        = aws_subnet.private
    aws_subnets_public         = aws_subnet.public
    aws_vpc                    = module.vpc.vpc
    internet_egress_sg         = aws_security_group.internet_proxy_endpoint
    internet_proxy_endpoint    = aws_vpc_endpoint.internet_proxy.dns_entry[0].dns_name
    tanium_service_endpoint    = aws_vpc_endpoint.tanium_service.dns_entry[0].dns_name
    tanium_service_endpoint_id = aws_security_group.tanium_service_endpoint.id
    s3_prefix_list_id          = module.vpc.prefix_list_ids.s3
    dynamodb_prefix_list_id    = module.vpc.prefix_list_ids.dynamodb
    route_tables_private       = aws_route_table.private
    no_proxy_list              = module.vpc.no_proxy_list
    interface_vpce_sg_id       = module.vpc.interface_vpce_sg_id
  }
}
