resource "aws_vpc_endpoint" "concourse" {
  #   count             = local.zone_count
  vpc_id            = module.vpc.vpc.id
  service_name      = "aws.concourse.endpoint"
  vpc_endpoint_type = "Interface"

  security_group_ids = [var.loadbalancer.security_group_id]

  subnet_ids          = ["aws_subnet.private.*.id"]
  private_dns_enabled = true
}

