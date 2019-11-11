resource "aws_security_group" "lb" {
  vpc_id = var.vpc.aws_vpc.id
  tags   = merge(var.tags, { Name = "${var.name}-lb" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "lb_external_https_in" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = var.whitelist_cidr_blocks
}

resource "aws_security_group_rule" "lb_internal_https_in" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = formatlist("%s/32", var.vpc.aws_nat_gateways[*].public_ip)
}
