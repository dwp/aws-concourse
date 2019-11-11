resource "aws_subnet" "private" {
  count                = local.zone_count
  cidr_block           = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + local.zone_count)
  vpc_id               = aws_vpc.main.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[count.index]
  tags                 = merge(var.tags, { Name = "${var.name}-private-${local.zone_names[count.index]}" })
}

resource "aws_route_table" "private" {
  count  = local.zone_count
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.name}-private-${local.zone_names[count.index]}" })

  route {
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
    cidr_block     = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "private" {
  count          = local.zone_count
  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = aws_subnet.private[count.index].id
}
