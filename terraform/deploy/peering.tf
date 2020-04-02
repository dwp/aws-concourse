resource "aws_vpc_peering_connection" "ucfs_github" {
  peer_owner_id = var.github_vpc.owner
  peer_vpc_id   = var.github_vpc.id
  peer_region   = var.github_vpc.region
  vpc_id        = module.vpc.outputs.aws_vpc.id

  requester {
    allow_classic_link_to_remote_vpc = false
    allow_remote_vpc_dns_resolution  = true
    allow_vpc_to_remote_classic_link = false
  }
}

resource "aws_route" "ucfs_github" {
  count                     = length(module.vpc.outputs.aws_route_table_private)
  route_table_id            = module.vpc.outputs.aws_route_table_private[count.index].id
  destination_cidr_block    = var.github_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.ucfs_github.id
}
