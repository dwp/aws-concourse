resource "aws_vpc_peering_connection" "ucfs_github" {
  peer_owner_id = var.github_vpc.owner
  peer_vpc_id   = var.github_vpc.id
  peer_region   = var.github_vpc.region
  vpc_id        = module.vpc.outputs.aws_vpc.id

  # Uncomment this when UCFS have accepted our connection request
  # requester {
  #   allow_remote_vpc_dns_resolution = true
  # }
}
