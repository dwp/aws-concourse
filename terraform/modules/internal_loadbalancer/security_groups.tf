resource "aws_security_group" "internal_lb" {
  vpc_id = var.vpc.aws_vpc.id
  tags   = merge(var.tags, { Name = "${var.name}-lb" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "internal_ssh_in" {
  description              = "enable inbound connectivity from whitelisted endpoints"
  from_port                = 2222
  protocol                 = "tcp"
  security_group_id        = aws_security_group.internal_lb.id
  to_port                  = 2222
  type                     = "ingress"
  source_security_group_id = var.concourse_web.security_group.id
}
