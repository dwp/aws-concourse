resource "aws_vpc_endpoint" "concourse" {
  count               = local.zone_count
  vpc_id              = module.vpc.vpc.id
  service_name        = "aws.concourse.endpoint"
  vpc_endpoint_type   = "Interface"

  security_group_ids  = [var.loadbalancer.security_group_id]

  subnet_ids          = [aws_subnet.private[count.index].id]
  private_dns_enabled = true
}


resource "aws_vpc_endpoint_service" "example" {
  acceptance_required        = false
  network_load_balancer_arns = [var.loadbalancer.arn]
}
