resource "aws_security_group" "worker" {
  vpc_id = var.vpc.aws_vpc.id
  tags   = merge(var.tags, { Name = local.name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "worker_all_out" {
  description       = "worker_all_out"
  from_port         = 0
  protocol          = "all"
  security_group_id = aws_security_group.worker.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "worker_lb_out_ssh" {
  description       = "worker_lb_out_ssh"
  from_port         = local.service_port
  protocol          = "tcp"
  security_group_id = aws_security_group.worker.id
  to_port           = local.service_port
  type              = "egress"
  cidr_blocks       = var.vpc.aws_subnets_private[*].cidr_block
}
