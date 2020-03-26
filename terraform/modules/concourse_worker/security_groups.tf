resource "aws_security_group" "worker" {
  vpc_id = var.vpc.aws_vpc.id
  tags   = merge(var.tags, { Name = local.name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "worker_lb_out_ssh" {
  description              = "outbound traffic to web nodes via lb"
  from_port                = local.service_port
  protocol                 = "tcp"
  security_group_id        = var.loadbalancer.security_group_id
  to_port                  = local.service_port
  type                     = "egress"
  source_security_group_id = aws_security_group.worker.id
}
