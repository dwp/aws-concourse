resource "aws_vpc_peering_connection" "ucfs_github" {
  peer_owner_id = var.github_vpc.owner
  peer_vpc_id   = var.github_vpc.id
  peer_region   = var.github_vpc.region
  vpc_id        = module.vpc.outputs.aws_vpc.id

  tags = {
    Name        = "ucfs_github"
    Environment = local.environment
  }

  requester {
    allow_remote_vpc_dns_resolution  = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route" "ucfs_github" {
  count                     = length(module.vpc.outputs.aws_route_table_private)
  route_table_id            = module.vpc.outputs.aws_route_table_private[count.index].id
  destination_cidr_block    = var.github_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.ucfs_github.id
}
