resource "aws_ec2_transit_gateway_vpc_attachment" "concourse" {
  subnet_ids         = module.vpc.outputs.aws_subnets_private.*.id
  transit_gateway_id = data.terraform_remote_state.internet_egress.outputs.internet_transit_gateway.id
  vpc_id             = module.vpc.outputs.aws_vpc.id
  tags = merge(
    local.tags,
    {
      Name = "concourse-${local.environment}",
    }
  )
}

resource "aws_ec2_transit_gateway_route_table" "concourse" {
  transit_gateway_id = data.terraform_remote_state.internet_egress.outputs.internet_transit_gateway.id

  tags = merge(
    local.tags,
    {
      Name = "concourse-${local.environment}",
    }
  )
}

resource "aws_ec2_transit_gateway_route_table_association" "concourse" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.concourse.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.concourse.id
}

resource "aws_ec2_transit_gateway_route" "internet_egress_to_concourse" {
  destination_cidr_block         = module.vpc.outputs.aws_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.concourse.id
  transit_gateway_route_table_id = data.terraform_remote_state.internet_egress.outputs.tgw_rtb_internet_egress.id
}

resource "aws_ec2_transit_gateway_route" "concourse_to_internet_proxy" {
  count                          = length(data.terraform_remote_state.internet_egress.outputs.proxy_subnet.cidr_blocks)
  destination_cidr_block         = element(data.terraform_remote_state.internet_egress.outputs.proxy_subnet.cidr_blocks, count.index)
  transit_gateway_attachment_id  = data.terraform_remote_state.internet_egress.outputs.tgw_attachment_internet_egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.concourse.id
}

resource "aws_route" "concourse_to_internet_proxy" {
  count                  = length(data.terraform_remote_state.internet_egress.outputs.proxy_subnet.cidr_blocks)
  destination_cidr_block = element(data.terraform_remote_state.internet_egress.outputs.proxy_subnet.cidr_blocks, count.index)
  route_table_id         = element(module.vpc.outputs.aws_route_table_private.*.id, count.index)
  transit_gateway_id     = data.terraform_remote_state.internet_egress.outputs.internet_transit_gateway.id
}

resource "aws_route" "internet_proxy_to_concourse" {
  count                  = length(data.terraform_remote_state.internet_egress.outputs.proxy_route_table.ids)
  destination_cidr_block = module.vpc.outputs.aws_vpc.cidr_block
  route_table_id         = element(data.terraform_remote_state.internet_egress.outputs.proxy_route_table.ids, count.index)
  transit_gateway_id     = data.terraform_remote_state.internet_egress.outputs.internet_transit_gateway.id
}
