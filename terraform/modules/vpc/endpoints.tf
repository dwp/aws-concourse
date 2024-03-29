resource "aws_security_group" "internet_proxy_endpoint" {
  name        = "proxy_vpc_endpoint"
  description = "Control access to the Internet Proxy VPC Endpoint"
  vpc_id      = module.vpc.vpc.id
  tags        = var.tags
}

resource "aws_vpc_endpoint" "internet_proxy" {
  vpc_id              = module.vpc.vpc.id
  service_name        = var.internet_proxy_service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.internet_proxy_endpoint.id]
  subnet_ids          = aws_subnet.private.*.id
  private_dns_enabled = false
}

resource "aws_security_group" "tanium_service_endpoint" {
  name        = "tanium_service_endpoint"
  description = "Control access to the Tanium Service VPC Endpoint"
  vpc_id      = module.vpc.vpc.id
}
resource "aws_vpc_endpoint" "tanium_service" {
  vpc_id              = module.vpc.vpc.id
  service_name        = var.tanium_service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.tanium_service_endpoint.id]
  subnet_ids          = aws_subnet.private.*.id
  private_dns_enabled = false
  tags = {
    Name = "tanium_service"
  }
}