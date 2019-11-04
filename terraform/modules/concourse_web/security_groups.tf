resource "aws_security_group" "web" {
  vpc_id = var.vpc.aws_vpc.id
  tags   = merge(var.tags, { Name = local.name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "web_lb_in_http" {
  description              = "web_lb_in_http"
  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  to_port                  = 8080
  type                     = "ingress"
  source_security_group_id = var.loadbalancer.security_group_id
}

resource "aws_security_group_rule" "lb_web_out_http" {
  description              = "lb_web_out_http"
  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = var.loadbalancer.security_group_id
  to_port                  = 8080
  type                     = "egress"
  source_security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_lb_in_ssh" {
  description       = "web_lb_in_ssh"
  from_port         = 2222
  protocol          = "tcp"
  security_group_id = aws_security_group.web.id
  to_port           = 2222
  type              = "ingress"
  cidr_blocks       = var.vpc.aws_subnets_private[*].cidr_block
}

resource "aws_security_group_rule" "web_all_out" {
  description       = "web_all_out"
  from_port         = 0
  protocol          = "all"
  security_group_id = aws_security_group.web.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "db_web_in" {
  description              = "db_web_in"
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = var.database.security_group_id
  to_port                  = 5432
  type                     = "ingress"
  source_security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_db_out" {
  description              = "web_db_out"
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  to_port                  = 5432
  type                     = "ingress"
  source_security_group_id = var.database.security_group_id
}
