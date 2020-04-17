resource "aws_vpc_endpoint_service" "concourse_internal" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.lb.arn]
  tags                       = var.tags
}

resource "aws_vpc_endpoint_service_allowed_principal" "concourse_internal" {
  count                   = length(var.concourse_internal_allowed_principals)
  vpc_endpoint_service_id = aws_vpc_endpoint_service.concourse_internal.id
  principal_arn           = var.concourse_internal_allowed_principals[count.index]
}
