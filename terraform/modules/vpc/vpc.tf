module "vpc" {
  source                                     = "dwp/vpc/aws"
  version                                    = "2.0.0"
  vpc_name                                   = "ci-cd"
  region                                     = data.aws_region.current.name
  vpc_cidr_block                             = var.vpc_cidr_block
  interface_vpce_source_security_group_count = 0
  interface_vpce_source_security_group_ids   = []
  interface_vpce_subnet_ids                  = aws_subnet.private.*.id
  gateway_vpce_route_table_ids               = aws_route_table.private.*.id
  s3_endpoint                                = true
  common_tags                                = merge(var.tags, { Name = var.name })
}
